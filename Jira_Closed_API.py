#pip install jira
#pip install pyodbc
import logging
import pyodbc
import requests
#import jira
import time
import os

from jira import JIRA
from datetime import datetime

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

def JIRA_Fields():
    print("List Fileds")
    issues = jira.issues()
    print (issues)
    for issue in issues: 
        print(f"{issue.key}: {issue.name}")

def SQLclose():
    # Close the connection
    cursor.close()
    cnxn.close()

def getMinMaxKey(sort):
    jql_query = f"project = 'AS' order by ID {sort}"        
    issues = jira.search_issues(jql_query, maxResults=1)      
    for issue in issues:                        
        KeyID = issue.id
    return KeyID

       

def procIssues(i):
    if i != 0:        
        jql_query = f"project = 'AS' AND ID >= {i} AND status in (Declined, Done, Canceled, Closed, Completed, Resolved) order by ID asc"
    else:
        print("EQUAL TO ZERO")
        jql_query = f"project = 'AS' AND status in (Declined, Done, Canceled, Closed, Completed, Resolved) order by ID asc"
    #100 is hard stop and cannot be changed, changing vaule to less then 100 will limit to set setlevel
    issues = jira.search_issues(jql_query, maxResults=100)  

    global start, idMax    
    for issue in issues:        
        fdata_sum = issue.fields.summary
        if fdata_sum is not None:        
            fdata_sum = fdata_sum.replace("'","`")            
        
        fdata_descr = issue.fields.description
        if fdata_descr is not None:
            fdata_descr = fdata_descr.replace("'","`")
            
        #print(f"Processing Ticket {issue.key} - {issue.id}")
        comments_a = issue.fields.comment.comments
        comments_b = jira.comments(issue) # comments_b == comments_a
        #author = jira.comment(issue.key, issue.id).author.displayName
        #time   = jira.comment(issue.key, issue.id).created
        #print("BEGIN COMMENTS")
        #print(comments_a)        
        #print("END COMMENTS")
        start = issue.id
        data =f"'{issue.key}'," \
              f"'{issue.id}'," \
              f"'{fdata_sum}'," \
              f"'{fdata_descr}'," \
              f"'{issue.fields.created}'," \
              f"''," \
              f"'{issue.fields.updated}'," \
              f"'{issue.fields.assignee}'," \
              f"''," \
              f"'{issue.fields.reporter}'," \
              f"''," \
              f"'{issue.fields.creator}'," \
              f"'{issue.fields.status}'"
        # Insert data into table    
        query=f"insert into jira.TicketsClosed VALUES ({data})"
        #print(query)
        if int(issue.id) > idMax:
            break
        try:
            cursor.execute(query)   # execute SQL
            cnxn.commit()           # Commit the transaction
        except Exception as e:
            SQLclose
            print(f"SYSTEM ERROR: Insert {issue.id} Key {issue.key}, try to update instead")
            #print(e)
            #try updating record
            query=f"update jira.TicketsClosed set Summary='{fdata_sum}'," \
                  f"Description='{fdata_descr}', Updated='{issue.fields.updated}', " \
                  f"Assignee='{issue.fields.assignee}', Status='{issue.fields.status}' where IssueID='{issue.id}'"     
            cursor.execute(query)
            cnxn.commit()
            #go to next record
    
# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
       
jira_url = require_env("JIRA_URL")
email    = require_env("JIRA_EMAIL") 
token    = require_env("JIRA_API_TOKEN")

server   = require_env("SQL_SERVER")
username = require_env("SQL_USERNAME")
password = require_env("SQL_PASSWORD")
database = require_env("SQL_DATABASE")

start_time = datetime.now()

# Establish connection to Jira
jira = JIRA(server=jira_url, basic_auth=(email, token))

# Establish connection to SQL Server
cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
cursor = cnxn.cursor()

#Truncate the SQL table
#cursor.execute("truncate table jira.Tickets_Closed")
#cnxn.commit()

#need to get max and min IDs, pass to function
idMax=int(getMinMaxKey("desc"))
idMin=int(getMinMaxKey("asc"))
#idMin=idMax-100
start=int(idMin)
print(f"Min {idMin} Max {idMax}")

#keep looping until we reach idMax value
for x in range(int(idMax)):
    print(f"Round {x+1} Start: {start}")
    procIssues(start)
    #increment by 1 to avoid duplicate for next round
    start=int(start)+1   
    #exit loop when end is reached.
    if start > idMax:    
        break
    
    
# Commit the transaction
cnxn.commit()

# Close the connection
cursor.close()
cnxn.close()

end_time = datetime.now()
# Calculate the difference
time_difference = end_time - start_time
# Convert to seconds, minutes, and hours
total_seconds = time_difference.total_seconds()
minutes       = total_seconds / 60
hours         = total_seconds / 3600
print(f"Start time: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
print(f"End time..: {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
print(f"Elapsed  : {total_seconds:.1f} seconds ({minutes:.2f} minutes)")

#if __name__ == "__main__":
#    main()   
