{{ config(
    materialized='table',
    schema='star_schema',
    tags=['star_schema']
) }}

SELECT DISTINCT
  TrackId AS track_id,
  PlaylistId AS playlist_id
FROM {{ source('music_db', 'PlaylistTrack') }}
WHERE TrackId IS NOT NULL AND PlaylistId IS NOT NULL