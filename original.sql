-- ZZEN9311 Assignment 2b
-- Schema for the mypics.net photo-sharing site
--
-- Written by <<YOUR NAME GOES HERE>>
--
-- Conventions:
-- * all entity table names are plural
-- * most entities have an artifical primary key called "id"
-- * foreign keys are named after the relationship they represent

-- Domains (you may add more)

create domain URLValue as
	varchar(100) check (value like 'https://%');

create domain EmailValue as
	varchar(100) check (value like '%@%.%');

create domain GenderValue as
	varchar(6) check (value in ('male','female'));

create domain GroupModeValue as
	varchar(15) check (value in ('private','by-invitation','by-request'));

create domain NameValue as varchar(50);

create domain LongNameValue as varchar(100);


-- Tables (you must add more)

create table People (
	id          serial,
	...
	primary key (id)
);

create table Users (
	...
	primary key (...)
);

create table Groups (
	...
	primary key (...)
);

create table Photos (
	...
	primary key (...)
);
