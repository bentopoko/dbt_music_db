{{ config(
    materialized='table',
    schema='star_schema',
    tags=['star_schema']
) }}

SELECT DISTINCT
  PlaylistId AS playlist_id,
  Name
FROM {{ source('music_db', 'Playlist') }}