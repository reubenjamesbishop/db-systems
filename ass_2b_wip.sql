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
	
    person_id                   INTEGER,
    family_name                 NameValue NOT NULL,
    given_names                 NameValue NOT NULL,
    displayed_name              LongNameValue, -- ASSUMPTION: mypics.net will create this value if not set initially
    email_address               EmailValue, -- ASSUMPTION: Email can be NULL at the Person level. 

	PRIMARY KEY (person_id)
);

CREATE TABLE Users (
    
    person              INTEGER,
    website             URLValue, --ASSUMPTION: not necessarily unique, assuming multiple people can share a website
    date_registered     DATE DEFAULT CURRENT_DATE, --ASSUMPTION: left as default value by mypics.net
    gender              GenderValue,
    birthday            DATE CHECK (birthday < CURRENT_DATE),
    password            VARCHAR(100) NOT NULL, --ASSUMPTION: password max 100 characters
    email_address       EmailValue NOT NULL, --ASSUMPTION: email_address mandatory for users.

    -- NOTE: Additional FK referencing user's portrait photo added later with ALTER TABLE statement
    FOREIGN KEY (person) REFERENCES People(person_id),
    PRIMARY KEY (person)

) INHERITS (People);

CREATE TABLE Groups (
    
    group_id    INTEGER,
    mode        GroupModeValue,
    title       TEXT NOT NULL, --ASSUMPTION: Arbritrary length string, i.e. "Family", "Workmates", "Friends" 
    owned_by    INTEGER NOT NULL,

    FOREIGN KEY (owned_by) REFERENCES Users(person),
	PRIMARY KEY (group_id)
);

CREATE TABLE Photos (

    photo_id            SERIAL, 
    date_taken          DATE,
    title               NameValue NOT NULL,
    date_uploaded       DATE DEFAULT CURRENT_DATE, --ASSUMPTION: The system automatically applies current date when uploaded
    description         TEXT,
    technical_details   TEXT,
    safety_level        SafetyLevelValue NOT NULL, --ASSUMPTION: mandatory value
    visibility          VisibilityValue NOT NULL, --ASSUMPTION: mandatory value
    file_size           INTEGER NOT NULL,  --ASSUMPTION: mandatory value
    owned_by            INTEGER NOT NULL,

    --NOTEL: FK for Photos Have Discussions referenced below with Alter Table
    FOREIGN KEY (owned_by) REFERENCES Users(person),
	PRIMARY KEY (photo_id)
);

CREATE TABLE Friends (

    friend_id   INTEGER,
    title       TEXT NOT NULL, --ASSUMPTION: Arbritrary length string
    owned_by    INTEGER NOT NULL,

    FOREIGN KEY (owned_by) REFERENCES Users(Person),
	PRIMARY KEY (friend_id)
);

CREATE TABLE Tags (
    tag_id  INTEGER,
    freq    INTEGER CHECK (freq >= 0) NOT NULL,  --ASSUMPTION: Not computed, mandatory and maintained by mypics.net application 
    name    NameValue NOT NULL, --ASSUMPTION: mandatory 

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
    FOREIGN KEY (owned_by) REFERENCES Users(person),
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
    contained_by    INTEGER NOT NULL,
    authored_by     INTEGER NOT NULL,

    -- Note: Additional FK for comments replying to comments added below with Alter Table
    FOREIGN KEY (contained_by) REFERENCES Discussions(discussion_id),
    FOREIGN KEY (authored_by) REFERENCES Users(person),
	PRIMARY KEY (comment_id)
);

-- Addition of missing foreign keys due to table ordering.
ALTER TABLE Comments ADD reply_to INTEGER REFERENCES Comments(comment_id);
ALTER TABLE Users ADD user_portrait INTEGER REFERENCES Photos(photo_id);
ALTER TABLE Photos ADD owned_discussion INTEGER REFERENCES Discussions(discussion_id);


-- Relation Tables

CREATE TABLE Person_member_Friends (
    
    person  INTEGER,
    friend  INTEGER NOT NULL,

    FOREIGN KEY (person) REFERENCES People(person_id),
    FOREIGN KEY (friend) REFERENCES Friends(friend_id),
	PRIMARY KEY (person, friend)
);

CREATE TABLE Users_member_Groups (

    "group"    INTEGER NOT NULL,
    "user"     INTEGER,

    FOREIGN KEY ("group") REFERENCES Groups(group_id),
    FOREIGN KEY ("user") REFERENCES People(person_id),
    PRIMARY KEY ("user", "group")
);


CREATE TABLE Users_rating_Photos (

    when_rated  TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    rating      RatingValue NOT NULL,
    "user"      INTEGER,
    photo       INTEGER,

    FOREIGN KEY ("user") REFERENCES Users(person),
    FOREIGN KEY (photo) REFERENCES Photos(photo_id),
    PRIMARY KEY ("user", photo)

);

CREATE TABLE Photos_have_Tags (

    when_tagged TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    tag         INTEGER NOT NULL,
    photo       INTEGER,

    FOREIGN KEY (tag) REFERENCES Tags(tag_id),
    FOREIGN KEY (photo) REFERENCES Photos(photo_id),
    PRIMARY KEY (photo, tag)
);

CREATE TABLE Photos_in_Collections (

    "order"         INTEGER CHECK ("order" > 0),  --Note: order/rank to allow ordering/ranking of photos
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

CREATE TABLE Users_have_Tags(

    "user"          INTEGER,
    tag             INTEGER,
    when_tagged     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("user") REFERENCES Users(person),
    FOREIGN KEY (tag) REFERENCES Tags(tag_id),
    PRIMARY KEY ("user", tag)

);
