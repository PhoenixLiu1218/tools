#region Imports

# import requests
from redminelib import Redmine
from dateutil.relativedelta import relativedelta
from datetime import datetime, timedelta
import json

#endregion

#region Global variables

status_dict = {}
targetStatus = 'Wait_CS'
repoter = ""

#endregion

#region Connection configuration

#region API part

redmine_url = "http://172.16.58.128"
api_key = "4b9644679baed77016eb3735c0baf7dd96f4b224"

# redmine_url = "http://172.28.4.200/redmine"
# api_key = "549762c7d415b82b5ce3a28e82973b66a4da2e8a"

redmine = Redmine(redmine_url,key=api_key)

#endregion

#region DB part



#endregion

#endregion

#region Functions

def setStatusId():
    result_all = redmine.issue_status.all()
    status_dict = {status.id: status.name for status in result_all}

    for status_id, name in status_dict.items():
        if targetStatus.lower() == str(name).lower():
            return status_id
    return None

#endregion

#region Ticket info

ticketStatus = setStatusId()

#endregion

#region Main

date = (datetime.today() - timedelta(days=3)).strftime("%Y-%m-%d")
issues = redmine.issue.filter(status_id=ticketStatus,updated_on=f"<={date}")

for issue in issues:
    print(f"ID: {issue.id}, Subject: {issue.subject},Last Updated: {issue.updated_on}")

#endregion