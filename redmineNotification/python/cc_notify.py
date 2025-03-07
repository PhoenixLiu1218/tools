import requests
import datetime
import json
import sys
import os
import dbQuery

applicationId = "81bc74a62c1affdd2327f4c14459c163"
clientKey = "d23816bbfba3880c7e2a82870d355a355fcb8ae2"
# 本番ルーム
roomId = "67ca53a9fc5db7001155aab3"
# テストルーム
# roomId = "64335e097673ba0036ffd222"
userId = "632a565dd84c921c943a0680"
msg = "\n"
urlCc = "https://mm.cybersolutions.co.jp:443/api/messages/sendMessageToRoom"


for i in dbQuery.getTicketID():
    # print(i)
    subject = dbQuery.selectFromDB('subject',str(i))
    lastUpdated = dbQuery.selectFromDB('lastUpdated',str(i))
    author = dbQuery.selectFromDB('author',str(i))
    ccName = dbQuery.getCCName(author[0])

    # if '開通準備中（未着手）' in status and '完了' in ki_status:
    msg += "@"+str(ccName[0])+"\n"
    msg += "```\n"
    msg += "---------Redmine リマインド通知---------\n"
    msg += "Ticket ID:" + str(i) +"\n"
    msg += "Subject:" + str(subject[0])+"\n"
    msg += "Status: " + "Wait_CS\n"
    # msg += "経過日数: " + "\n"
    msg += "Last_updated: " + str(lastUpdated[0].strftime("%Y-%m-%d %H:%M:%S")) + "\n"
    msg += "---------------------------------------\n"
    msg += "```\n"
    msg += "\n"
    msg += "https://redmine.office.openfind.com.tw/issues/" + str(i) + "\n"
    msg += "\n"

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