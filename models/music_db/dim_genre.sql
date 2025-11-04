{{ config(
    materialized='table',
    schema='star_schema',
    tags=['star_schema']
) }}

SELECT DISTINCT
  GenreId AS genre_id,
  Name AS genre_name
FROM {{ source('music_db', 'Genre') }}