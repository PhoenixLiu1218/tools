import os
from redminelib import Redmine
from dateutil.relativedelta import relativedelta
from datetime import datetime, timedelta
from csv import DictWriter

def getUserID(name):
    userID = redmine.user.filter(name='{}'.format(name))
    return userID.id

redmine_url = "https://redmine.office.openfind.com.tw/"
api_key = "0c0fdc47d644bb54d0bf75a23e8d00d734be9df1"

redmine = Redmine(redmine_url,key=api_key)

if __name__ == '__main__':
    issue = redmine.issue.get(68495)
    print(issue.author.id)