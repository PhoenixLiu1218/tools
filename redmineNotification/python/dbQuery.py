#region Imports

# from redminelib import Redmine
import mysql.connector
from mysql.connector import Error
import pathlib
import csv

#endregion

#region Connection configuration

#region API part

# home test
# redmine_url = "http://172.16.58.128"
# api_key = "4b9644679baed77016eb3735c0baf7dd96f4b224"

# company test
# redmine_url = "http://172.28.4.200/redmine"
# api_key = "549762c7d415b82b5ce3a28e82973b66a4da2e8a"

# OF
# redmine_url = "https://redmine.office.openfind.com.tw/"
# api_key = "0c0fdc47d644bb54d0bf75a23e8d00d734be9df1"

# Docker
# redmine_url = "https://redmine.office.openfind.com.tw/"
# api_key = "0c0fdc47d644bb54d0bf75a23e8d00d734be9df1"

# redmine = Redmine(redmine_url,key=api_key)

#endregion

#region DB part

connection = mysql.connector.connect(
    host='mysql',  # データベースホスト名
    port="3306",
    database='test',  # 使用するデータベース名
    user='root',  # データベースユーザー名
    password='123'  # データベースユーザーパスワード
)

#endregion

#endregion

csv_path = "/var/lib/python/data/list.csv"

def insertIssueInfo(issue_id,subject,author,last_updated):
    #   MySQLデータベースに接続
    if connection.is_connected():
        cursor = connection.cursor()
        # データを挿入するSQL文
        sql_insert_query = """INSERT INTO issue (issueId,subject,author,lastUpdated) VALUES (%s, %s, %s, %s)"""
        # データを挿入する
        cursor.execute(sql_insert_query, (issue_id,subject,author,last_updated))
        # 変更をコミット
        connection.commit()

def getTicketID():
    if connection.is_connected():
        cursor = connection.cursor()
        # データを挿入するSQL文
        sql_insert_query = """select issueId from issue"""
        # データを挿入する
        cursor.execute(sql_insert_query)
        issueID = cursor.fetchall()

        if issueID is not None:
            return [row[0] for row in issueID]

def getCCName(authorName):
    if connection.is_connected():
        cursor = connection.cursor()
        # データを挿入するSQL文
        sql_insert_query = "select ccName from authorList where author='{}'".format(authorName)
        # データを挿入する
        cursor.execute(sql_insert_query)
        ccName = cursor.fetchall()

        if ccName is not None:
            return ccName[0]

def selectFromDB(column,ticketID):
    if connection.is_connected():
        cursor = connection.cursor()
        # データを挿入するSQL文
        sql_insert_query = "select {} from issue where issueId='{}'".format(column,ticketID)
        # データを挿入する
        cursor.execute(sql_insert_query)
        result = cursor.fetchall()

        if result is not None:
            return result[0]

if __name__ == '__main__':
    dict_list = list()
    with open(csv_path,'r') as csv_reader:
        csv_reader = csv.reader(csv_reader)
        for rows in csv_reader:
            dict_list.append({'ID':rows[0],'Subject':rows[1],'Author':rows[2],'Last Updated':rows[3]})

    for item in dict_list:
        insertIssueInfo(item['ID'],item['Subject'],item['Author'],item['Last Updated'])

    connection.close()