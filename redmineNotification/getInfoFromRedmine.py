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

redmine_url = "http://http://172.28.4.200/redmine"
api_key = "549762c7d415b82b5ce3a28e82973b66a4da2e8a"

server = Redmine(redmine_url,key=api_key)
project = server.projects.all

#endregion

#region Ticket info

ticketStatus = "Wait_CS"
repoter = "test"
lastUpdatedTime = ""

#endregion

#region Functions



#endregion

for issue in project.issues:
    print(issue)




# url = (f"{redmine_url}/projects/{project_id}/issues.json?key={api_key}"
#        f"&updated_on=><{start_date}|{end_date}")



# end_date = datetime.now().date()
# start_date = end_date - timedelta(days=30)


# response = requests.get(url)

# if response.status_code == 200:
#     issues = response.json()

#     formatted_issues = json.dumps(issues, indent=4, ensure_ascii=False)
#     print(formatted_issues)
# else:
#     print("Error:", response.status_code, response.text)