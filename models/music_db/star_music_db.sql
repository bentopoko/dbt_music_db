-- Create schema
USE DATABASE MUSIC_DB;
CREATE SCHEMA IF NOT EXISTS star_schema;
USE SCHEMA star_schema;


-- Create star_schema tables

-- dimArtist
CREATE OR REPLACE TABLE dimArtist (
  artist_id NUMBER PRIMARY KEY,
  name VARCHAR,
  birthyear NUMBER,
  country VARCHAR
);

-- dimAlbum
CREATE OR REPLACE TABLE dimAlbum (
  album_id NUMBER PRIMARY KEY,
  title VARCHAR,
  artist_id NUMBER,
  artist_name VARCHAR,
  prod_year NUMBER,
  cd_year NUMBER
);

-- dimMediaType
CREATE OR REPLACE TABLE dimMediaType (
  media_type_id NUMBER PRIMARY KEY,
  name VARCHAR
);

-- dimPlaylist
CREATE OR REPLACE TABLE dimPlaylist (
  playlist_id NUMBER PRIMARY KEY,
  name VARCHAR
);

-- factTrack
CREATE OR REPLACE TABLE factTrack (
  track_id NUMBER PRIMARY KEY,
  name VARCHAR,
  album_id NUMBER,
  album_title VARCHAR,
  artist_id NUMBER,
  artist_name VARCHAR,
  genre_id NUMBER,
  genre_name VARCHAR,
  media_type_id NUMBER,
  media_type_name VARCHAR,
  composer VARCHAR,
  milliseconds NUMBER,
  bytes NUMBER,
  unit_price NUMBER
);

-- factTrackPlaylist
CREATE OR REPLACE TABLE factTrackPlaylist (
  track_id NUMBER REFERENCES factTrack(track_id),
  playlist_id NUMBER REFERENCES dimPlaylist(playlist_id),
  PRIMARY KEY (track_id, playlist_id)
);

-- Refresh all tables
TRUNCATE TABLE IF EXISTS dimArtist;
TRUNCATE TABLE IF EXISTS dimAlbum;
TRUNCATE TABLE IF EXISTS dimMediaType;
TRUNCATE TABLE IF EXISTS dimPlaylist;
TRUNCATE TABLE IF EXISTS factTrack;
TRUNCATE TABLE IF EXISTS factTrackPlaylist;


-- Insert data into star schema tables

-- dimArtist
INSERT INTO dimArtist (artist_id, name, birthyear, country)
SELECT DISTINCT ArtistId, Name, Birthyear, Country
FROM PUBLIC.Artist;

-- dimAlbum
INSERT INTO dimAlbum (
  album_id, title, artist_id, artist_name, prod_year, cd_year
)
SELECT
  a.AlbumId,
  a.Title,
  a.ArtistId,
  ar.Name AS artist_name,
  a.Prod_year,
  a.Cd_year
FROM PUBLIC.Album a
JOIN PUBLIC.Artist ar ON a.ArtistId = ar.ArtistId;

-- dimMediaType
INSERT INTO dimMediaType (media_type_id, name)
SELECT DISTINCT MediaTypeId, Name
FROM PUBLIC.MediaType;

-- dimPlaylist
INSERT INTO dimPlaylist (playlist_id, name)
SELECT DISTINCT PlaylistId, Name
FROM PUBLIC.Playlist;

-- factTrack
INSERT INTO factTrack (
  track_id, name, album_id, album_title, artist_id, artist_name,
  genre_id, genre_name, media_type_id, media_type_name,
  composer, milliseconds, bytes, unit_price
)
SELECT
  t.TrackId,
  t.Name,
  t.AlbumId,
  al.Title,
  ar.ArtistId,
  ar.Name,
  g.GenreId,
  g.Name,
  m.MediaTypeId,
  m.Name,
  t.Composer,
  t.Milliseconds,
  t.Bytes,
  t.UnitPrice
FROM PUBLIC.Track t
LEFT JOIN PUBLIC.Album al ON t.AlbumId = al.AlbumId
LEFT JOIN PUBLIC.Artist ar ON al.ArtistId = ar.ArtistId
LEFT JOIN PUBLIC.Genre g ON t.GenreId = g.GenreId
LEFT JOIN PUBLIC.MediaType m ON t.MediaTypeId = m.MediaTypeId;

-- factTrackPlaylist
INSERT INTO factTrackPlaylist (track_id, playlist_id)
SELECT DISTINCT TrackId, PlaylistId
FROM PUBLIC.PlaylistTrack
WHERE TrackId IS NOT NULL AND PlaylistId IS NOT NULL;