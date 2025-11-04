-- Use appropriate warehouse
USE WAREHOUSE warehouse_DST;

-- Use or create database and schema
CREATE DATABASE IF NOT EXISTS music_db;
USE DATABASE music_db;
CREATE SCHEMA IF NOT EXISTS public;
USE SCHEMA public;

-- File Format: Classic CSV
CREATE OR REPLACE FILE FORMAT classic_csv
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE'
  NULL_IF = ('\\N')
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

-- File Format to tolerate column mismatches
CREATE OR REPLACE FILE FORMAT csv_error
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE'
  NULL_IF = ('\\N')
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

-- Create Tables

-- MediaType Table
CREATE OR REPLACE TABLE MediaType (
  MediaTypeId NUMBER PRIMARY KEY,
  Name VARCHAR
);

-- Genre Table
CREATE OR REPLACE TABLE Genre (
  GenreId NUMBER PRIMARY KEY,
  Name VARCHAR
);

-- Artist Table
CREATE OR REPLACE TABLE Artist (
  ArtistId NUMBER PRIMARY KEY,
  Name VARCHAR,
  Birthyear NUMBER,
  Country VARCHAR
);

-- Album Table
CREATE OR REPLACE TABLE Album (
  AlbumId NUMBER PRIMARY KEY,
  Title VARCHAR,
  ArtistId NUMBER REFERENCES Artist(ArtistId),
  Prod_year NUMBER,
  Cd_year NUMBER
);

-- Playlist Table
CREATE OR REPLACE TABLE Playlist (
  PlaylistId NUMBER PRIMARY KEY,
  Name VARCHAR
);

-- Track Table
CREATE OR REPLACE TABLE Track (
  TrackId NUMBER PRIMARY KEY,
  Name VARCHAR,
  MediaTypeId NUMBER REFERENCES MediaType(MediaTypeId),
  GenreId NUMBER REFERENCES Genre(GenreId),
  AlbumId NUMBER REFERENCES Album(AlbumId),
  Composer VARCHAR,
  Milliseconds NUMBER,
  Bytes NUMBER,
  UnitPrice NUMBER
);

-- PlaylistTrack Table
CREATE OR REPLACE TABLE PlaylistTrack (
  PlaylistId NUMBER REFERENCES Playlist(PlaylistId),
  TrackId NUMBER REFERENCES Track(TrackId),
  PRIMARY KEY (PlaylistId, TrackId)
);

-- Copy Data from S3 Stage

-- MediaType
COPY INTO MediaType
FROM @s3_data/sample/music/MediaType.csv
FILE_FORMAT = (FORMAT_NAME = classic_csv)
ON_ERROR = 'CONTINUE';

-- Genre
COPY INTO Genre
FROM @s3_data/sample/music/Genre.csv
FILE_FORMAT = (FORMAT_NAME = classic_csv)
ON_ERROR = 'CONTINUE';

-- Artist
COPY INTO Artist
FROM @s3_data/sample/music/Artist.csv
FILE_FORMAT = (FORMAT_NAME = classic_csv)
ON_ERROR = 'CONTINUE';

-- Album
COPY INTO Album
FROM @s3_data/sample/music/Album.csv
FILE_FORMAT = (FORMAT_NAME = classic_csv)
ON_ERROR = 'CONTINUE';

-- Playlist
COPY INTO Playlist
FROM @s3_data/sample/music/Playlist.csv
FILE_FORMAT = (FORMAT_NAME = classic_csv)
ON_ERROR = 'CONTINUE';

-- Track
COPY INTO Track
FROM @s3_data/sample/music/Track.csv
FILE_FORMAT = (FORMAT_NAME = csv_error)
ON_ERROR = 'CONTINUE';

-- PlaylistTrack
COPY INTO PlaylistTrack
FROM @s3_data/sample/music/PlaylistTrack.csv
FILE_FORMAT = (FORMAT_NAME = classic_csv)
ON_ERROR = 'CONTINUE';