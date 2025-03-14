FROM oraclelinux:9

WORKDIR /opt

COPY getInfoFromRedmine.py ./

COPY dbQuery.py ./

COPY cc_notify.py ./

COPY test.py ./

RUN dnf install -y python3.11 pip

RUN pip3 install python-redmine mysql-connector-python python-dateutil