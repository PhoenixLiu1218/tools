#region TODO

# get the data by api


#endregion

#region Imports

# import requests
from redminelib import Redmine
from dateutil.relativedelta import relativedelta
from datetime import datetime, timedelta
import json

#endregion

#region API configuration

# redmine_url = "http://172.16.58.128"
# api_key = "4b9644679baed77016eb3735c0baf7dd96f4b224"

redmine_url = "http://172.28.4.200/redmine"
api_key = "549762c7d415b82b5ce3a28e82973b66a4da2e8a"

server = Redmine(redmine_url,key=api_key)
project = server.issue.all()

#endregion

#region Ticket info

ticketStatus = "Wait_CS"
repoter = "test"
lastUpdatedTime = ""

#endregion

#region Functions


#endregion

#region Main

for issue in project:
    print(f"ID: {issue.id}")
    print(f"Subject: {issue.subject}")
    # print(f"Description: {issue.description}")
    print(f"Status: {issue.status}")
    # print(f"Priority: {issue.priority}")
    print(f"Author: {issue.author}")
    # print(f"Assigned to: {issue.assigned_to}")
    print(f"Created on: {issue.created_on}")
    print(f"Updated on: {issue.updated_on}")
    print("-" * 40)

#endregion