{{ config(
    materialized='ephemeral',
    tags=['query_views']
) }}

{% do create_star_views() %}
SELECT 1 AS dummy