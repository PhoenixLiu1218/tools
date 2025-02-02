#region TODO

# get the data by api


#endregion

#region Imports

import requests 
from datetime import datetime, timedelta
import json

#endregion

#region API configuration

redmine_url = "http://172.16.58.128"
api_key = "4b9644679baed77016eb3735c0baf7dd96f4b224"
project_id = "test"

#endregion

#region Ticket info

ticketStatus = "Wait_CS"
repoter = ""
lastUpdatedTime = ""

#endregion

#region Functions



#endregion





end_date = datetime.now().date()
start_date = end_date - timedelta(days=30)

url = (f"{redmine_url}/projects/{project_id}/issues.json?key={api_key}"
       f"&updated_on=><{start_date}|{end_date}")

response = requests.get(url)

if response.status_code == 200:
    issues = response.json()

    formatted_issues = json.dumps(issues, indent=4, ensure_ascii=False)
    print(formatted_issues)
else:
    print("Error:", response.status_code, response.text)