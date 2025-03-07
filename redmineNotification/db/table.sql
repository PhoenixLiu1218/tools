-- create database test;

use test;

DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS issue;
DROP TABLE IF EXISTS authorList;

create table if not exists authorList(
    userId varchat(50) not null,
    author varchar(50) not null,
    ccName varchar(50) not null,
    PRIMARY KEY(userId)
);

create table if not exists issue(
    id int AUTO_INCREMENT not null,
    issueId int not null,
    subject varchar(1000) not null,
    author varchar(50) not null,
    lastUpdated DATETIME not null,
    PRIMARY KEY(id),
    FOREIGN KEY(author) REFERENCES authorList(author)
);

INSERT INTO authorList (userId,author,ccName) VALUES ('','Phoenix Liu','p-liu');
INSERT INTO authorList (userId,author,ccName) VALUES ('','shima shima','shima');
INSERT INTO authorList (userId,author,ccName) VALUES ('','izukura izukura','izukura');
INSERT INTO authorList (userId,author,ccName) VALUES ('','shin shin','shin');