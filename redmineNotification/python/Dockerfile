FROM oraclelinux:9

WORKDIR /opt

COPY infoUpdate.py ./

COPY getInfoFromRedmine.py ./

RUN dnf install -y python3.11 pip

RUN pip3 install python-redmine mysql-connector-python python-dateutil