{{ config(
    materialized='table',
    schema='star_schema',
    tags=['star_schema']
) }}

SELECT DISTINCT
  ArtistId AS artist_id,
  Name,
  Birthyear,
  Country
FROM {{ source('music_db', 'Artist') }}