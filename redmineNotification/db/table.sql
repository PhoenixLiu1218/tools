-- create database test;

use test;

DROP TABLE IF EXISTS user;

create table if not exists issue(
    id int AUTO_INCREMENT not null,
    issueId int not null,
    subject varchar(1000) not null,
    lastUpdated datetime not null,
    PRIMARY KEY(id)
);