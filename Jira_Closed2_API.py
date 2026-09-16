import logging
import os
import sys
import time
from datetime import datetime

import pyodbc
from jira import JIRA
from dotenv import load_dotenv

load_dotenv()

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PROJECT_KEY = "AS"
CLOSED_STATUSES = ("Declined", "Done", "Canceled", "Closed", "Completed", "Resolved")
BATCH_SIZE = 100
TABLE = "jira.TicketsClosed"

# Fields we actually need from Jira - keeps each API response small.
JIRA_FIELDS = "summary,description,created,updated,assignee,reporter,creator,status"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
log = logging.getLogger("jira_sync")


def require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        log.error("Missing required environment variable: %s", name)
        sys.exit(1)
    return value


def load_config():
    return {
        "jira_url":     require_env("JIRA_URL"),
        "jira_email":   require_env("JIRA_EMAIL"),
        "jira_token":   require_env("JIRA_API_TOKEN"),
        "sql_server":   require_env("SQL_SERVER"),
        "sql_database": require_env("SQL_DATABASE"),
        "sql_username": require_env("SQL_USERNAME"),
        "sql_password": require_env("SQL_PASSWORD"),
    }


# ---------------------------------------------------------------------------
# Helpers for pulling clean values out of Jira objects
# ---------------------------------------------------------------------------

def person_name(person_obj):
    """Return a display name for a Jira user field, or None if unset."""
    if person_obj is None:
        return None
    return getattr(person_obj, "displayName", None) or getattr(person_obj, "name", None)


def status_name(status_obj):
    if status_obj is None:
        return None
    return getattr(status_obj, "name", str(status_obj))


def get_last_synced_id(cursor):
    """Resume from the highest IssueID already stored, if any."""
    cursor.execute(f"SELECT MAX(CAST(IssueID AS BIGINT)) FROM {TABLE}")
    row = cursor.fetchone()
    if row and row[0] is not None:
        return int(row[0])
    return 0


# ---------------------------------------------------------------------------
# Jira <-> SQL sync
# ---------------------------------------------------------------------------

def build_jql(last_id: int) -> str:
    status_list = ", ".join(CLOSED_STATUSES)
    if last_id:
        return (
            f"project = '{PROJECT_KEY}' AND id > {last_id} "
            f"AND status in ({status_list}) ORDER BY id ASC"
        )
    return (
        f"project = '{PROJECT_KEY}' AND status in ({status_list}) ORDER BY id ASC"
    )


def upsert_issue(cursor, issue) -> None:
    summary = issue.fields.summary
    description = issue.fields.description
    created = issue.fields.created
    updated = issue.fields.updated
    assignee = person_name(issue.fields.assignee)
    reporter = person_name(issue.fields.reporter)
    creator = person_name(issue.fields.creator)
    status = status_name(issue.fields.status)

    update_sql = f"""
        UPDATE {TABLE}
        SET Summary = ?, Description = ?, Updated = ?, Assignee = ?, Status = ?
        WHERE IssueID = ?
    """
    cursor.execute(
        update_sql, summary, description, updated, assignee, status, issue.id
    )

    if cursor.rowcount and cursor.rowcount > 0:
        return  # existing row updated, done

    insert_sql = f"""
        INSERT INTO {TABLE}
            (IssueKey, IssueID, Summary, Description, Created, Resolved,
             Updated, Assignee, AssigneeID, Reporter, ReporterID,
             Creator, Status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    cursor.execute(
        insert_sql,
        issue.key,
        issue.id,
        summary,
        description,
        created,
        "",
        updated,
        assignee,
        "",
        reporter,
        "",
        creator,
        status,
    )


def sync_closed_issues(jira_client, cnxn, cursor) -> int:
    last_id = get_last_synced_id(cursor)
    log.info("Resuming sync after IssueID %s", last_id)

    total_synced = 0
    start_at = 0

    while True:
        jql_query = build_jql(last_id)
        issues = jira_client.search_issues(
            jql_query,
            startAt=start_at,
            maxResults=BATCH_SIZE,
            fields=JIRA_FIELDS,
        )
        if not issues:
            break

        for issue in issues:
            try:
                upsert_issue(cursor, issue)
                cnxn.commit()
                total_synced += 1
            except Exception:
                log.exception("Failed to sync issue %s (%s)", issue.key, issue.id)
                cnxn.rollback()

        log.info("Synced batch of %d issues (running total: %d)", len(issues), total_synced)

        if len(issues) < BATCH_SIZE:
            break  # last page
        start_at += BATCH_SIZE

    return total_synced


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    config = load_config()
    start_time = time.perf_counter()
    start_dt = datetime.now()
    log.info("Start time: %s", start_dt.strftime("%Y-%m-%d %H:%M:%S"))

    jira_client = JIRA(server=config["jira_url"], basic_auth=(config["jira_email"], config["jira_token"]))

    conn_str = (
        "DRIVER={SQL Server};"
        f"SERVER={config['sql_server']};"
        f"DATABASE={config['sql_database']};"
        f"UID={config['sql_username']};"
        f"PWD={config['sql_password']}"
    )

    with pyodbc.connect(conn_str) as cnxn:
        cursor = cnxn.cursor()
        try:
            total_synced = sync_closed_issues(jira_client, cnxn, cursor)
        finally:
            cursor.close()

    end_dt = datetime.now()
    elapsed_seconds = time.perf_counter() - start_time

    log.info("End time: %s", end_dt.strftime("%Y-%m-%d %H:%M:%S"))
    log.info("Issues synced: %d", total_synced)
    log.info("Elapsed: %.1f minutes (%.0f seconds)", elapsed_seconds / 60, elapsed_seconds)


if __name__ == "__main__":
    main()
