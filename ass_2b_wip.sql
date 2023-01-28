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

create domain SafetyLevelValue as VARCHAR(10) check (value in ('safe', 'moderate', 'restricted'));

create domain VisibilityValue as VARCHAR(14) check (value in ('private', 'friends', 'family', 'friends+family', 'public'));

create domain RatingValue as INTEGER check (value between 0 and 5);


-- Entity Tables

CREATE TABLE People (
	
    person_id                       INTEGER, -- or SERIAL (?)
    family_name NameValue           NOT NULL, --i.e. "Smith"
    given_names NameValue           NOT NULL, --i.e. "John Michael Adam"
    displayed_name LongNameValue    DEFAULT NULL, -- assuming that family and given name values are strictly NOT NULL (update later)
    email_address EmailValue,

	PRIMARY KEY (person_id)
);

UPDATE People SET displayed_name = (given_names || family_name) WHERE displayed_name IS NULL;  -- replace NULL displayed names with concat of given and family names -- should be ALTER TABLE (?)

CREATE TABLE Users (
    
    person              INTEGER,
    website             URLValue, --not necessarily unique, assuming multiple people can share a website
    DATE_registered     DATE DEFAULT CURRENT_DATE,
    gender              GenderValue,
    birthday            DATE, --check not in future (?)
    password            VARCHAR(20) NOT NULL, -- ok (?)
    
    --FOREIGN KEY (user_portrait) references Photos(photo_id), -- (?) ALTER TABLE LATER!
    --FOREIGN KEY (email_address) references People(person_id) UNIQUE NOT NULL, -- (?) FIX THIS, email comes from People
    --FOREIGN KEY (own) references Friend(friend_id), (?) No reference to friend in user table, friend referenecs user instead
    FOREIGN KEY (person) references People(person_id),
    PRIMARY KEY (person)
);

CREATE TABLE Groups (
    
    group_id    INTEGER,
    mode        GroupModeValue,
    title       TEXT NOT NULL, --i.e. "Family"
    owned_by    INTEGER NOT NULL,

    FOREIGN KEY (owned_by) REFERENCES Users(person),
	PRIMARY KEY (group_id)
);

CREATE TABLE Photos (

    photo_id            INTEGER, -- or SERIAL (?)
    DATE_taken          DATE DEFAULT CURRENT_DATE, -- may be supplied but defaults to uploaded DATE,
    title NameValue     NOT NULL,
    DATE_uploaded       DATE DEFAULT CURRENT_DATE,
    description         TEXT, -- is description a key word (?)
    technical_details   TEXT,
    safety_level        SafetyLevelValue NOT NULL,
    visibility          VisibilityValue NOT NULL,
    file_size           INTEGER NOT NULL,
    owned_by            INTEGER UNIQUE NOT NULL, --UNIQUE= (?)

    FOREIGN KEY (owned_by) REFERENCES Users(person),
	PRIMARY KEY (photo_id)
);

CREATE TABLE Friends (

    friend_id   INTEGER,
    title       TEXT NOT NULL,
    owned_by    INTEGER NOT NULL,

    FOREIGN KEY (owned_by) REFERENCES Users(Person),
	PRIMARY KEY (friend_id)
);

CREATE TABLE Tags (
    tag_id  INTEGER,
    freq    SERIAL,  -- Note: refers to tag count, auto-incremented INTEGER
    name    NameValue, 

	PRIMARY KEY (tag_id)
);

CREATE TABLE Collections (

    collection_id   INTEGER,
    title           NameValue NOT NULL,
    description     TEXT, 
    key_photo       INTEGER NOT NULL,

    FOREIGN KEY (key_photo) REFERENCES Photos(photo_id),
	PRIMARY KEY (collection_id)
);

CREATE TABLE UserCollections (
    
    collection  INTEGER,
    owned_by    INTEGER NOT NULL,

    FOREIGN KEY (collection) REFERENCES Collections(collection_id),
    FOREIGN KEY (owned_by) REFERENCES Users(Person),
    PRIMARY KEY (collection)
);

CREATE TABLE GroupCollections (

	collection  INTEGER,
    owned_by    INTEGER NOT NULL,

    FOREIGN KEY (collection) REFERENCES Collections(collection_id),
    FOREIGN KEY (owned_by) REFERENCES Groups(group_id),
    PRIMARY KEY (collection)
);

CREATE TABLE Discussions(

    discussion_id   INTEGER,
    title           NameValue,

	PRIMARY KEY (discussion_id)
);

CREATE TABLE Comments (

    comment_id      INTEGER,
    when_posted     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content         TEXT NOT NULL,
    discussion      INTEGER NOT NULL,
    authored_by     INTEGER NOT NULL,

    FOREIGN KEY (discussion) REFERENCES Discussions(discussion_id),
    FOREIGN KEY (authored_by) REFERENCES Users(person),
	PRIMARY KEY (comment_id)
);

-- Relation Tables

CREATE TABLE Person_member_Friends (
    -- this needs a check... (?)
    
    person  INTEGER NOT NULL,
    friend  INTEGER NOT NULL,

    FOREIGN KEY (person) REFERENCES People(person_id),
    FOREIGN KEY (friend) REFERENCES Friends(friend_id), --or another person?
	PRIMARY KEY (person, friend)
);

CREATE TABLE Users_member_Groups (
    -- add group owner as member by default (?)
    "group"    INTEGER NOT NULL,
    "user"     INTEGER,

    FOREIGN KEY ("group") REFERENCES Groups(group_id),
    FOREIGN KEY ("user") REFERENCES People(person_id),
    PRIMARY KEY ("user", "group")
);


CREATE TABLE Users_rating_Photos (

    when_rated  TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    rating      RatingValue,
    "user"      INTEGER,
    photo       INTEGER,

    FOREIGN KEY ("user") REFERENCES Users(Person),
    FOREIGN KEY (photo) REFERENCES Photos(photo_id),
    PRIMARY KEY ("user", photo)

);

CREATE TABLE Photos_have_Tags (

    when_tagged TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    tag         INTEGER,
    photo       INTEGER,

    FOREIGN KEY (tag) REFERENCES Tags(tag_id),
    FOREIGN KEY (photo) REFERENCES Photos(photo_id),
    PRIMARY KEY (photo, tag)
);

CREATE TABLE Photos_in_Collections (

    "order"         INTEGER CHECK ("order" > 0),  -- order/rank to allow ordering/ranking of photos
    collection_id   INTEGER NOT NULL,
    photo_id        INTEGER NOT NULL,

    FOREIGN KEY (collection_id) REFERENCES Collections(collection_id),
    FOREIGN KEY (photo_id) REFERENCES Photos(photo_id),
    PRIMARY KEY (collection_id, photo_id)

);

CREATE TABLE Groups_have_Discussions(

    "group"         INTEGER,
    "discussion"    INTEGER,

    FOREIGN KEY ("group") REFERENCES Groups(group_id),
    FOREIGN KEY ("discussion") REFERENCES Discussions(discussion_id),
    PRIMARY KEY ("group", "discussion")

);
