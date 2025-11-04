{{ config(
    materialized='table',
    schema='star_schema',
    tags=['star_schema']
) }}

SELECT
  t.TrackId AS track_id,
  t.Name,
  t.AlbumId AS album_id,
  al.Title AS album_title,
  ar.ArtistId AS artist_id,
  ar.Name AS artist_name,
  g.GenreId AS genre_id,
  g.Name AS genre_name,
  m.MediaTypeId AS media_type_id,
  m.Name AS media_type_name,
  t.Composer,
  t.Milliseconds,
  t.Bytes,
  t.UnitPrice AS unit_price
FROM {{ source('music_db', 'Track') }} t
LEFT JOIN {{ source('music_db', 'Album') }} al ON t.AlbumId = al.AlbumId
LEFT JOIN {{ source('music_db', 'Artist') }} ar ON al.ArtistId = ar.ArtistId
LEFT JOIN {{ source('music_db', 'Genre') }} g ON t.GenreId = g.GenreId
LEFT JOIN {{ source('music_db', 'MediaType') }} m ON t.MediaTypeId = m.MediaTypeId