/**
ISYS2120 2020 S2 Assignment 03 Media Server Database
Prepared by: Ryan Skelton, Harshana Randeni

You should only need to alter the Helper functions at the bottom of the file
If you do make any changes to the schema, please note them in your report

*/

drop schema if exists mediaserver cascade;
create schema mediaserver;
set search_path to 'mediaserver';


DROP TABLE IF EXISTS UserAccount CASCADE;
DROP TABLE IF EXISTS ContactType CASCADE;
DROP TABLE IF EXISTS ContactMethod CASCADE;
DROP TABLE IF EXISTS MediaItem CASCADE;
DROP TABLE IF EXISTS UserMediaConsumption CASCADE;
DROP TABLE IF EXISTS MediaCollection CASCADE;
DROP TABLE IF EXISTS MediaCollectionContents CASCADE;
DROP TABLE IF EXISTS AudioMedia CASCADE;
DROP TABLE IF EXISTS Podcast CASCADE;
DROP TABLE IF EXISTS PodcastEpisode CASCADE;
DROP TABLE IF EXISTS Subscribed_Podcasts CASCADE;
DROP TABLE IF EXISTS Artist CASCADE;
DROP TABLE IF EXISTS Album CASCADE;
DROP TABLE IF EXISTS Song CASCADE;
DROP TABLE IF EXISTS Album_Songs CASCADE;
DROP TABLE IF EXISTS Song_Artists CASCADE;
DROP TABLE IF EXISTS Song_Featured_Artists CASCADE;
DROP TABLE IF EXISTS BandMembership CASCADE;
DROP TABLE IF EXISTS VideoMedia CASCADE;
DROP TABLE IF EXISTS Movie CASCADE;
DROP TABLE IF EXISTS TVShow CASCADE;
DROP TABLE IF EXISTS TVEpisode CASCADE;
DROP TABLE IF EXISTS MetaDataType CASCADE;
DROP TABLE IF EXISTS MetaData CASCADE;
DROP TABLE IF EXISTS MetaDataAssociated CASCADE;
DROP TABLE IF EXISTS MetaDataPermittedAssociations CASCADE;
DROP TABLE IF EXISTS MediaItemMetaData CASCADE;
DROP TABLE IF EXISTS AlbumMetaData CASCADE;
DROP TABLE IF EXISTS ArtistMetaData CASCADE;
DROP TABLE IF EXISTS TVShowMetaData CASCADE;
DROP TABLE IF EXISTS PodcastMetaData CASCADE;

CREATE TABLE UserAccount (
    username VARCHAR(50) PRIMARY KEY,
    password VARCHAR(72) NOT NULL,
    isSuper boolean DEFAULT FALSE 
);

CREATE TABLE ContactType(
    contact_type_id SERIAL PRIMARY KEY,
    contact_type_name VARCHAR(50)
);

CREATE TABLE ContactMethod(
    username varchar(50) references UserAccount(username),
    contact_type_id INTEGER REFERENCES ContactType(contact_type_id),
    contact_type_value VARCHAR(100),
    PRIMARY KEY(username, contact_type_id, contact_type_value)
);

CREATE TABLE MediaItem (
    media_id SERIAL PRIMARY KEY,
    storage_location text NOT NULL
);

CREATE TABLE MetaDataType (
    md_type_id SERIAL PRIMARY KEY,
    md_type_name VARCHAR (100) NOT NULL
);

CREATE TABLE MetaData (
    md_id BIGSERIAL PRIMARY KEY,
    md_type_id INTEGER REFERENCES MetaDataType(md_type_id) NOT NULL,
    md_value text NOT NULL
);

CREATE TABLE MetaDataAssociated (
    md_id_current BIGINT REFERENCES MetaData(md_id),
    md_id_associated BIGINT REFERENCES MetaData(md_id),
    PRIMARY KEY (md_id_current,md_id_associated)
);

CREATE TABLE MetaDataPermittedAssociations (
    md_type_id_current INTEGER REFERENCES MetaDataType(md_type_id),
    md_type_id_associated INTEGER REFERENCES MetaDataType(md_type_id),
    PRIMARY KEY (md_type_id_current,md_type_id_associated)
);

CREATE TABLE MediaItemMetaData (
    media_id INTEGER REFERENCES MediaItem(media_id),
    md_id BIGINT REFERENCES MetaData(md_id),
    PRIMARY KEY (media_id,md_id)
);

CREATE TABLE UserMediaConsumption (
    username varchar(50) REFERENCES UserAccount(username),
    media_id INTEGER REFERENCES MediaItem(media_id),
    play_count INTEGER,
    progress DECIMAL NOT NULL,
    lastviewed DATE NOT NULL,
    PRIMARY KEY (username,media_id)
);

CREATE TABLE MediaCollection (
    collection_id SERIAL PRIMARY KEY,
    username varchar(50) REFERENCES UserAccount(username) NOT NULL,
    collection_name varchar (100) NOT NULL
);

CREATE TABLE MediaCollectionContents (
    collection_id INTEGER REFERENCES MediaCollection(collection_id),
    media_id INTEGER REFERENCES MediaItem(media_id),
    PRIMARY KEY (collection_id,media_id)
);

CREATE TABLE AudioMedia (
    media_id INTEGER NOT NULL,
    FOREIGN KEY (media_id) REFERENCES MediaItem (media_id),
    PRIMARY KEY (media_id)
);

CREATE TABLE Podcast (
    podcast_id SERIAL PRIMARY KEY,
    podcast_title VARCHAR(250),
    podcast_uri text,
    podcast_last_updated DATE
);

CREATE TABLE PodcastEpisode (
    podcast_id INTEGER NOT NULL REFERENCES Podcast(podcast_id),
    media_id INTEGER NOT NULL REFERENCES AudioMedia(media_id),
    podcast_episode_title VARCHAR(250),
    podcast_episode_URI text NOT NULL,
    podcast_episode_published_date DATE,
    podcast_episode_length INTEGER,
    PRIMARY KEY (podcast_id,media_id)
);


CREATE TABLE Subscribed_Podcasts (
    username varchar(50) NOT NULL REFERENCES UserAccount (username),
    podcast_id INTEGER NOT NULL REFERENCES Podcast (podcast_id),
    PRIMARY KEY (username, podcast_id)
);

CREATE TABLE Artist (
    artist_name VARCHAR(100),
    artist_id SERIAL PRIMARY KEY
);

CREATE TABLE Album (
    album_id SERIAL PRIMARY KEY,
    album_title VARCHAR(250) NOT NULL
);

CREATE TABLE Song (
    song_id INTEGER PRIMARY KEY REFERENCES AudioMedia(media_id),
    song_title VARCHAR(100),
    length INTEGER
);

CREATE TABLE Album_Songs(
    song_id INTEGER REFERENCES Song(song_id),
    album_id INTEGER REFERENCES Album(album_id),
    track_num INTEGER NOT NULL,
    PRIMARY KEY(song_id,album_id)
);

CREATE TABLE Song_Artists(
    song_id INTEGER REFERENCES Song(song_id),
    performing_artist_id INTEGER REFERENCES Artist(artist_id),
    PRIMARY KEY(song_id,performing_artist_id)
);

-- Depreciated in our new Schema
-- CREATE TABLE Song_Featured_Artists(
--     song_id INTEGER REFERENCES Song(song_id),
--     featured_artist_id INTEGER REFERENCES Artist(artist_id),
--     PRIMARY KEY(song_id,featured_artist_id)
-- );


CREATE TABLE BandMembership(
    band_association_id SERIAL PRIMARY KEY,
    band_id INTEGER REFERENCES Artist(artist_id),
    band_member_id INTEGER REFERENCES Artist(artist_id),
    joinDate DATE NOT NULL,
    departureDate DATE
);

CREATE TABLE AlbumMetaData (
    album_id INTEGER REFERENCES Album(album_id),
    md_id BIGINT REFERENCES MetaData(md_id),
    PRIMARY KEY (album_id,md_id)
);

CREATE TABLE ArtistMetaData (
    artist_id INTEGER REFERENCES Artist(artist_id),
    md_id BIGINT REFERENCES MetaData(md_id),
    PRIMARY KEY (artist_id,md_id)
);

CREATE TABLE VideoMedia (
    media_id INTEGER PRIMARY KEY REFERENCES MediaItem(media_id)
);

-- child entity to VideoMedia
CREATE TABLE Movie (
    movie_id INTEGER REFERENCES VideoMedia(media_id) PRIMARY KEY,
    movie_title VARCHAR(250),
    release_year SMALLINT
);

CREATE TABLE TVShow (
    tvshow_id SERIAL PRIMARY KEY,
    tvshow_title VARCHAR(250)
);

-- weak entity to TVShow
-- child entity to VideoMedia
CREATE TABLE TVEpisode(
    media_id INTEGER REFERENCES VideoMedia(media_id),
    tvshow_id INTEGER REFERENCES TVShow(tvshow_id),
    tvshow_episode_title VARCHAR(250),
    season INTEGER,
    episode INTEGER,
    air_date DATE,
    PRIMARY KEY(media_id,tvshow_id,season,episode)
);

CREATE TABLE TVShowMetaData (
    tvshow_id INTEGER REFERENCES TVShow(tvshow_id),
    md_id BIGINT REFERENCES MetaData(md_id),
    PRIMARY KEY (tvshow_id,md_id)
);

CREATE TABLE PodcastMetaData (
    podcast_id INTEGER REFERENCES Podcast(podcast_id),
    md_id BIGINT REFERENCES MetaData(md_id),
    PRIMARY KEY (podcast_id,md_id)
);

--------------------------
-- Helper Functions     --
--------------------------
-- Function to add a movie with some associated metadata
-- Call it using 'Select addmovie([paramaters]);'
-- Example: SELECT mediaserver.addMovie('Empty storage location','Empty description field','Empty Film Value','0','drama');

create or replace function mediaserver.addmovie(
	location text,
	moviedescription text,
	title varchar(250),
	releaseyear int,
	filmgenre text)
RETURNS int AS
$BODY$
	WITH ins1 AS (
        INSERT INTO mediaserver.mediaItem(storage_location)
        VALUES (location)
        RETURNING media_id
        )
        , ins2 AS (
        INSERT INTO mediaserver.metadata (md_type_id,md_value)
        SELECT md_type_id, moviedescription
        FROM mediaserver.MetaDataType where md_type_name = 'description'
        RETURNING md_id
        )
        , ins3 AS (
        INSERT INTO mediaserver.VideoMedia
        SELECT media_id FROM ins1
        )
        ,ins4 AS (
        INSERT INTO mediaserver.Movie
        SELECT media_id, title, releaseyear FROM ins1
        )
        ,ins5 AS (
        INSERT INTO mediaserver.metadata (md_type_id,md_value)
        SELECT md_type_id, filmgenre
        FROM mediaserver.MetaDataType where md_type_name = 'film genre'
        RETURNING md_id as genre_md_id
        )
        ,ins6 AS (
        INSERT INTO mediaserver.MediaItemMetaData
        SELECT media_id, genre_md_id FROM ins1, ins5
        )
        INSERT INTO mediaserver.MediaItemMetaData
        SELECT media_id, md_id FROM ins1, ins2;

        SELECT max(movie_id) as movie_id FROM mediaserver.movie;
$BODY$
LANGUAGE sql;

-- Function to add a song with some associated metadata
-- Call it using 'Select addsong([paramaters]);'
-- Example: SELECT mediaserver.addSong('no location','no description','Empty Song','0','pop','33');
-- TODO :: Part 9, handle the proper insertion of a song
create or replace function mediaserver.addSong(
	location text,
	songdescription text,
	title varchar(250),
	songlength int,
	songgenre text,
    artistid int,
    artwork text)
RETURNS int AS
$BODY$
WITH ins1 AS (
    INSERT INTO mediaserver.mediaItem(storage_location)
    VALUES (location)
    RETURNING media_id
    )
    , ins2 AS (
    INSERT INTO mediaserver.metadata (md_type_id,md_value)
    SELECT md_type_id, songdescription
    FROM mediaserver.MetaDataType where md_type_name = 'description'
    RETURNING md_id
    )
    , ins3 AS (
    INSERT INTO mediaserver.AudioMedia
    SELECT media_id FROM ins1
    )
    ,ins4 AS (
    INSERT INTO mediaserver.Song
    SELECT media_id, title, songlength FROM ins1
    )
    ,ins5 AS (
    INSERT INTO mediaserver.metadata (md_type_id,md_value)
    SELECT md_type_id, songgenre
    FROM mediaserver.MetaDataType where md_type_name = 'song genre'
    RETURNING md_id as genre_md_id
    )
    ,ins6 AS (
    INSERT INTO mediaserver.MediaItemMetaData
    SELECT media_id, genre_md_id FROM ins1, ins5
    ), ins7 AS (
    INSERT INTO mediaserver.Song_Artists
    SELECT media_id, artistid FROM ins1
    ), ins8 AS (
    INSERT INTO mediaserver.metadata (md_type_id,md_value)
    SELECT md_type_id, artwork
    FROM mediaserver.MetaDataType where md_type_name = 'artwork'
    RETURNING md_id as genre_md_id
    ), ins9 AS (
    INSERT INTO mediaserver.MediaItemMetaData
    SELECT media_id, genre_md_id FROM ins1, ins8
    )
    INSERT INTO mediaserver.MediaItemMetaData
    SELECT media_id, md_id FROM ins1, ins2;

    SELECT max(song_id) as song_id FROM mediaserver.song;
$BODY$
LANGUAGE sql;


-- Insert password with more secure storage
-- to check the password:
--      select * 
--      from mediaserver.useraccount 
--      where username = 'whatevertheuseris' and password = public.crypt('whateverthepasswordis',password);
CREATE OR REPLACE FUNCTION mediaserver.storeSecurePassword(
    username VARCHAR(50),
    password VARCHAR(100))
RETURNS void AS
$$
    DECLARE
        -- you would have any variables declared here
    BEGIN
		INSERT INTO mediaserver.UserAccount (username, password) VALUES
  			(lower(username), public.crypt(password, public.gen_salt('bf', 8)));
    END;
$$
LANGUAGE plpgsql;
