import requests
import datetime
import json
import base64
import datetime
from monthdelta import monthmod
import sys
import smtplib
from email.mime.text import MIMEText
from email.utils import formatdate
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv
import os

# accesstokenの代わり
applicationId = "81bc74a62c1affdd2327f4c14459c163"
clientKey = "d23816bbfba3880c7e2a82870d355a355fcb8ae2"
roomId = "6392d8fdce44da002f59abf5"

date_30_days_ago = datetime.datetime.now() - datetime.timedelta(days=30)
date_str = date_30_days_ago.strftime("%Y-%m-%dT%H:%M:%SZ")
headers = {'Content-Type': 'application/json',
           'X-Cybozu-API-Token': 'XXXXXXXXXLPMgBd'}
appId = 23
base_url = 'https://XXXXXXXhh.cybozu.com/k/v1'
url = '{}/records/cursor.json'.format(base_url)
data = {
    'app': appId,
    'query': f'更新日時 > "{date_str}"'
}
response = requests.post(url, headers=headers, json=data)
j_response = response.json()
print(j_response)
cursorId = j_response["id"]
data["id"] = cursorId

applicationId = "XXXX81bc74a62c1affdd2327f4c14459c163XXXX"
clientKey = "XXXXd23816bbfba3880c7e2a82870d355a355fcb8ae2XXXX"
roomId = "6392d8fdce44da002f59abf5"
userId = "60a45e66cd7a0e10af41fe02"
urlCc = "XXXXhttps://mm.cybersolutions.co.jp:443/api/messages/sendMessageToRoomXXXX"

next_flag = 0
while next_flag == 0:
    response = requests.get(url, headers=headers, json=data)
    j_response = response.json()
    if j_response["next"] is False:
        next_flag = 1

    for i in j_response["records"]:
        status = i["ステータス_1"]["value"]
        id = i["レコード番号"]["value"]
        company_name = i["ご契約社名"]["value"]
        ki_status = i["Kintone入力ステータス"]["value"]
        period_date = i["開通希望日"]["value"]

        if '開通準備中（未着手）' in status and '完了' in ki_status:
            msg = ""
            msg += "**サポートIDの発行をお願いします**\n"
            msg += "ステータス: " + "``" + status + "``" + "\n"
            msg += "ご契約社名: " + company_name + "\n"
            msg += "https://9keyb8lwayhh.cybozu.com/k/23/show#record=" + id
            headersCc = {
                'Content-Type': 'application/json'
            }
            parames = {
                'applicationId': applicationId,
                'userId': userId,
                'roomId': roomId,
                'clientKey': clientKey,
                'text': msg
            }
            response = requests.post(urlCc, headers=headersCc, params=parames)
            print(id)
            print(response)
            print(response.json())

        if '開通準備中（CO-G作業完了）' in status and '完了' in ki_status:
            msg = ""
            msg += "**サポートIDの発行をお願いします**\n"
            msg += "ステータス: " + "``" + status + "``" + "\n"
            msg += "ご契約社名: " + company_name + "\n"
            msg += "https://9keyb8lwayhh.cybozu.com/k/23/show#record=" + id
            headersCc = {
                'Content-Type': 'application/json'
            }
            parames = {
                'applicationId': applicationId,
                'userId': userId,
                'roomId': roomId,
                'clientKey': clientKey,
                'text': msg
            }
            response = requests.post(
                urlCc, headers=headersCc, params=parames)
            print(id)
            print(response)
            print(response.json())