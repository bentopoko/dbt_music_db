{% macro create_star_views() %}

-- 1. Donnez les titres des albums qui ont plus de 1 CD.
CREATE OR REPLACE VIEW {{ target.schema }}.view_albums_more_than_one_cd AS
SELECT DISTINCT title
FROM {{ ref('dim_album') }}
WHERE cd_year > 1;

-- 2. Donnez les morceaux produits en 2000 ou en 2002.
CREATE OR REPLACE VIEW {{ target.schema }}.view_tracks_produced_in_2000_or_2002 AS
SELECT f.name AS track_name
FROM {{ ref('fact_track') }} f
JOIN {{ ref('dim_album') }} a ON f.album_id = a.album_id
WHERE a.prod_year IN (2000, 2002);

-- 3. Donnez le nom et le compositeur des morceaux de Rock et de Jazz.
CREATE OR REPLACE VIEW {{ target.schema }}.view_rock_jazz_tracks_with_composer AS
SELECT name AS track_name, composer
FROM {{ ref('fact_track') }}
WHERE LOWER(genre_name) IN ('rock', 'jazz');

-- 4. Donnez les 10 albums les plus longs.
CREATE OR REPLACE VIEW {{ target.schema }}.view_top_10_longest_albums AS
SELECT album_title, SUM(milliseconds) AS total_duration_ms
FROM {{ ref('fact_track') }}
GROUP BY album_title
ORDER BY total_duration_ms DESC
LIMIT 10;

-- 5. Donnez le nombre d'albums produits pour chaque artiste. Number is 204 it should be 275 !??
CREATE OR REPLACE VIEW {{ target.schema }}.view_album_count_by_artist AS
SELECT artist_name, COUNT(*) AS nb_albums
FROM {{ ref('dim_album') }}
GROUP BY artist_name;

-- 6. Donnez le nombre de morceaux produits par chaque artiste.
CREATE OR REPLACE VIEW {{ target.schema }}.view_track_count_by_artist AS
SELECT artist_name, COUNT(*) AS nb_tracks
FROM {{ ref('fact_track') }}
GROUP BY artist_name;

-- 7. Donnez le genre de musique le plus écouté dans les années 2000.
CREATE OR REPLACE VIEW {{ target.schema }}.view_most_listened_genre_in_2000s AS
SELECT genre_name, COUNT(*) AS nb_tracks
FROM {{ ref('fact_track') }} f
JOIN {{ ref('dim_album') }} a ON f.album_id = a.album_id
WHERE a.prod_year BETWEEN 2000 AND 2009
GROUP BY genre_name
ORDER BY nb_tracks DESC
LIMIT 1;

-- 8. Donnez les noms de toutes les playlists où figurent des morceaux de plus de 4 minutes.
CREATE OR REPLACE VIEW {{ target.schema }}.view_playlists_with_tracks_over_4min AS
SELECT DISTINCT p.name
FROM {{ ref('fact_track') }} f
JOIN {{ ref('fact_track_playlist') }} fp ON f.track_id = fp.track_id
JOIN {{ ref('dim_playlist') }} p ON fp.playlist_id = p.playlist_id
WHERE f.milliseconds > 240000;

-- 9. Donnez les morceaux de Rock dont les artistes sont en France. 
CREATE OR REPLACE VIEW {{ target.schema }}.view_rock_tracks_by_french_artists AS
SELECT f.name AS track_name
FROM {{ ref('fact_track') }} f
JOIN {{ ref('dim_artist') }} a ON f.artist_id = a.artist_id
WHERE LOWER(f.genre_name) = 'rock' AND LOWER(a.country) = 'france';

-- 10. Donnez la moyenne des tailles des morceaux par genre musical. It should be 25 genres but it's giving only 5.
CREATE OR REPLACE VIEW {{ target.schema }}.view_avg_track_size_by_genre AS
SELECT genre_name, ROUND(AVG(bytes)) AS avg_track_size_bytes
FROM {{ ref('fact_track') }}
GROUP BY genre_name;

-- 11. Donnez les playlist où figurent des morceaux d'artistes nés avant 1990. 
CREATE OR REPLACE VIEW {{ target.schema }}.view_playlists_with_artists_born_before_1990 AS
SELECT DISTINCT p.name
FROM {{ ref('fact_track') }} f
JOIN {{ ref('dim_artist') }} a ON f.artist_id = a.artist_id
JOIN {{ ref('fact_track_playlist') }} fp ON f.track_id = fp.track_id
JOIN {{ ref('dim_playlist') }} p ON fp.playlist_id = p.playlist_id
WHERE a.birthyear < 1990;

{% endmacro %}