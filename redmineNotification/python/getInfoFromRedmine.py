#region Imports

import os
from redminelib import Redmine
from dateutil.relativedelta import relativedelta
from datetime import datetime, timedelta
from csv import DictWriter

#endregion

#region API part

# home test
# redmine_url = "http://172.16.58.128"
# api_key = "4b9644679baed77016eb3735c0baf7dd96f4b224"

# company test
# redmine_url = "http://172.28.4.200/redmine"
# api_key = "549762c7d415b82b5ce3a28e82973b66a4da2e8a"

# OF
redmine_url = "https://redmine.office.openfind.com.tw/"
api_key = "0c0fdc47d644bb54d0bf75a23e8d00d734be9df1"

redmine = Redmine(redmine_url,key=api_key)

#endregion


targetStatus = 'Wait_CS'
author = ""
csv_path = "/var/lib/python/data/list.csv"

def setStatusId():
    result_all = redmine.issue_status.all()
    status_dict = {status.id: status.name for status in result_all}

    for status_id, name in status_dict.items():
        if targetStatus.lower() == str(name).lower():
            return status_id
    return None

def getID():
    user = redmine.user.get('current')
    # print(f"User ID: {user.id}, Login: {user.login}, Name: {user.firstname} {user.lastname}")
    return user.id


ticketStatus = setStatusId()
userID = getID()


date = (datetime.today() - timedelta(days=1)).strftime("%Y-%m-%d")

issues = redmine.issue.filter(status_id=ticketStatus,updated_on=f"<={date}",author_id=userID)
issue_dict={}
field_names = ['ID','Subject','Last Updated']

if issues:
    with open(csv_path,'a') as file:
        for info in issues:
            issue_dict.update({'ID': info.id,'Subject': info.subject,'Last Updated': info.updated_on})
            writer_object = DictWriter(file,fieldnames=field_names )
            writer_object.writerow(issue_dict)
    file.close()