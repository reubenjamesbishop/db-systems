-- ZZEN9311 Assignment 2b
-- Schema for the mypics.net photo-sharing site
--
-- Written by Reuben James Bishop
--
-- Conventions:
-- * all entity table names are plural
-- * most entities have an artifical PRIMARY KEY called "id"
-- * FOREIGN KEYs are named after the relationship they represent

-- Domains (you may add more)

create domain URLValue as VARCHAR(100) check (value like 'https://%');

create domain EmailValue as VARCHAR(100) check (value like '%@%.%');

create domain GenderValue as VARCHAR(6) check (value in ('male','female'));

create domain GroupModeValue as VARCHAR(15) check (value in ('private','by-invitation','by-request'));

create domain NameValue as VARCHAR(50);

create domain LongNameValue as VARCHAR(100);


-- Entity Tables

CREATE TABLE People (
	
    person_id INTEGER, -- or SERIAL (?)
    family_name NameValue NOT NULL, --i.e. "Smith"
    given_names NameValue NOT NULL, --i.e. "John Michael Adam"
    displayed_name LongNameValue DEFAULT (given_names || family_name) --fine, b/c both are NOT NULL
    email_address EmailValue,

	PRIMARY KEY (person_id)
);

CREATE TABLE Users (
    
    person INTEGER,
    website URLValue, --not necessarily unique, assuming multiple people can share a website
    DATE_registered DATE DEFAULT CURRENT_DATE,
    gender GenderValue,
    birthday DATE,
    password VARCHAR(20) NOT NULL, -- ok (?)

    FOREIGN KEY (person) references People(person_id),
    FOREIGN KEY (user_portrait) references Photos(photo_id),
    FOREIGN KEY (email) references People(person_id) UNIQUE NOT NULL,
    FOREIGN KEY (own) references Friend(friend_id),
    PRIMARY KEY (person),
);

CREATE TABLE Groups (
    
    group_id INTEGER,
    mode VARCHAR(13) CHECK (VALUE IN ('private', 'by-invitation', 'by-request')), -- do we need NOT NULL too? (?)\
    title TEXT NOT NULL, --i.e. "Family"

    owned_by INTEGER REFERENCES User(person) NOT NULL,
	PRIMARY KEY (group_id)
);

CREATE TABLE Photos (

    photo_id INTEGER, -- or SERIAL (?)
    DATE_taken DATE DEFAULT CURRENT_DATE, -- may be supplied but defaults to uploaded DATE,
    title NameValue NOT NULL,
    DATE_uploaded DATE DEFAULT CURRENT_DATE,
    description TEXT, -- is description a key word (?)
    technical_details TEXT,
    safety_level VARCHAR(10) CHECK (VALUE IN ('safe', 'moderate', 'restricted')) NOT NULL,
    visibility VARCHAR(14) CHECK (VALUE IN ('private', 'friends', 'family', 'friends+family', 'public')) NOT NULL,
    file_size INTEGER NOT NULL,

    owned_by references Users(Person) UNIQUE NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE Friends (

    friend_id INTEGER,
    title TEXT NOT NULL, -- i.e. "Family", "Workmates", "Friends"
    
    owned_by INTEGER REFERENCES Users(Person) NOT NULL,
	PRIMARY KEY (friend_id)
);

CREATE TABLE Tags (
    tag_id INTEGER
    freq SERIAL,  --refers to tag count, auto-incremented INTEGER
    name NameValue, 

	PRIMARY KEY (tag_id)
);

CREATE TABLE Collections (

    collection_id INTEGER,
    title NameValue NOT NULL,
    description TEXT, 

    key_photo INTEGER REFERENCES Photo(photo_id) NOT NULL,
	PRIMARY KEY (collection_id)
);

CREATE TABLE UserCollections (
    
    collection INTEGER,
    owned_by TEXT REFERENCES Users(Person) NOT NULL,

    PRIMARY KEY (collection),
    FOREIGN KEY (collection) REFERENCES Collections(collection_id)
);

CREATE TABLE GroupCollections (

	collection INTEGER,
    owned_by TEXT REFERENCES Groups(group_id) NOT NULL,

    PRIMARY KEY (collection),
    FOREIGN KEY (collection) REFERENCES Collections(collection_id)
);

CREATE TABLE Discussions(

    discussion_id INTEGER,
    title NameValue,

	PRIMARY KEY (discussion_id)
);

CREATE TABLE Comments (

    comment_id INTEGER,
    when_posted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL,

    discussion INTEGER REFERENCES Discussions(discussion_id) NOT NULL,
    authored_by INTEGER REFERENCES Users(person) NOT NULL, -- (?)

	PRIMARY KEY (comment_id)
);


-- Relation Tables

CREATE TABLE FriendMembers (

    -- this needs a check... (?)
    person INTEGER REFERENCES People(person_id),
    friend INTEGER REFERENCES Friends(friend_id) NOT NULL,

	PRIMARY KEY (person, friend)
);

CREATE TABLE GroupMembers (

    -- add group owner as member by default?
    group INTEGER REFERENCES Groups(group_id) NOT NULL,  -- TBD (?)
    user INTEGER REFERENCES Users(Person),
	
    PRIMARY KEY (user, group)
);

CREATE TABLE PhotoRatings (

    when_rated timestamp DEFAULT CURRENT_TIMESTAMP, 
    rating INTEGER CHECK (VALUE IN (1, 2, 3, 4, 5)), 
    
    user INTEGER REFERENCES Users(Person),
    photo INTEGER REFERENCES Photos(photo_id),
    PRIMARY KEY (user, photo)

);

CREATE TABLE Photos_in_Tags (

    when_tagged timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL, 

    tag INTEGER REFERENCES Tags(tag_id),
    photo INTEGER REFERENCES Photos(photo_id),
    PRIMARY KEY (photo, tag)
);


CREATE TABLE Photos_in_Collections (

    collection_id INTEGER REFERENCES Collections(collection_id) NOT NULL,
    photo_id INTEGER REFERENCES Photos(photo_id) NOT NULL,
    
    order INTEGER CHECK (order > 0)  -- order/rank to allow ordering/ranking of photos
    PRIMARY KEY (collection_id, photo_id)

);