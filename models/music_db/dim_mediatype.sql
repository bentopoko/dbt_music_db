{{ config(
    materialized='table',
    schema='star_schema',
    tags=['star_schema']
) }}

SELECT DISTINCT
  MediaTypeId AS media_type_id,
  Name
FROM {{ source('music_db', 'MediaType') }}