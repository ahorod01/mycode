#pip install jira
#pip install pyodbc
import pyodbc
import jira
import time
import os
import logging

from datetime import datetime
from jira import JIRA

from dotenv import load_dotenv

load_dotenv()

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PROJECT_KEY = "AS"
CLOSED_STATUSES = ("Declined", "Done", "Canceled", "Closed", "Completed", "Resolved")
BATCH_SIZE = 100
TABLE = "jira.TicketsOpen"

# Fields we actually need from Jira - keeps each API response small.
JIRA_FIELDS = "summary,description,created,updated,assignee,reporter,creator,status"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
log = logging.getLogger("jira_sync")


def require_env(name: str) -> str:
    #values set in .env file
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


def wrap_text(text, width):
    wrapped_lines = textwrap.wrap(text, width=width)
    return "\n".join(wrapped_lines)

def JIRA_Projects():
    #list JIRA projects
    projects = jira.projects() 
    for project in projects: 
        print(f"{project.key}: {project.name}")

def SQLclose():
    # Commit the transaction
    cnxn.commit()
    # Close the connection
    cursor.close()
    cnxn.close()

def main():
    jira_url = require_env("JIRA_URL")
    email    = require_env("JIRA_EMAIL") 
    token    = require_env("JIRA_API_TOKEN")

    server   = require_env("SQL_SERVER")
    username = require_env("SQL_USERNAME")
    password = require_env("SQL_PASSWORD")
    database = require_env("SQL_DATABASE")

    current_dt = datetime.now()
    formatted  = current_dt.strftime("%Y-%m-%d %H:%M:%S")
    print("Start Time: ",formatted )
    # Establish connection 
    jira = JIRA(server=jira_url, basic_auth=(email, token))

    # Establish connection
    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = cnxn.cursor()

    #show open tickets
    cursor.execute("truncate table jira.TicketsOpen")   #truncate Table before populating

    jql_query = "status not in (Declined, Done, Canceled, Closed, Completed, Resolved, 'Order Complete', 'To Do')"
    issues = jira.search_issues(jql_query, maxResults=100) 
    for issue in issues:    
        #print(f"{issue.key} - {issue.fields.summary}")
    
        fdata_sum = issue.fields.summary
        if fdata_sum is not None:        
            fdata_sum = fdata_sum.replace("'","`")
        
    
        fdata_descr = issue.fields.description
        if fdata_descr is not None:
            fdata_descr = fdata_descr.replace("'","`")
    
        data =f"'{issue.key}'," \
              f"'{fdata_sum}'," \
              f"'{fdata_descr}'," \
              f"'{issue.fields.reporter}'," \
              f"'{issue.fields.assignee}'," \
              f"'{issue.fields.status}','{issue.fields.creator}','{issue.fields.created}','{issue.fields.updated}'"
        # Insert data into table    
        query=f"insert into jira.TicketsOpen VALUES ({data})"
        #print(query)
        try:
            cursor.execute(query)
        except Exception as e:
            SQLclose
            print("SYSTEM ERROR")
            print(e)
            break
    
    current_dt = datetime.now()
    formatted  = current_dt.strftime("%Y-%m-%d %H:%M:%S")
    print("End Time: ",formatted )
    
    # Commit the transaction
    cnxn.commit()
    # Close the connection
    cursor.close()
    cnxn.close()

if __name__ == "__main__":
    main()    


