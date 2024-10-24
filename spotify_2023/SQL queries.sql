use spotify_tracks;
select * from spotify_2023;


### `A. General Song Information`

# 1. What are the top 5 most streamed songs in 2023?

SELECT   track_name,
         streams
FROM     spotify
WHERE    released_year = 2023
ORDER BY streams DESC
LIMIT    5;

# 2. How many unique artists contributed to the dataset?

SELECT COUNT(DISTINCT artist_name) AS unique_artists
FROM spotify;

# 3. What is the distribution of songs across different release years?

SELECT   CONCAT(FLOOR(released_year / 10) * 10, '-', FLOOR(released_year / 10) * 10 + 11) AS decade_range,
         COUNT(*) AS songs_count
FROM     spotify
GROUP BY 1
ORDER BY 1;

# 4. Who are the top 10 artists based on popularity, and what are their tracks' average danceability and energy?

SELECT 
    artist_name, 
    SUM(streams) AS total_streams, 
    AVG(danceability) AS avg_danceability, 
    AVG(energy) AS avg_energy
FROM 
    spotify
GROUP BY 
    artist_name
ORDER BY 
    total_streams DESC
LIMIT 10;


### `B. Spotify Metrics`

# 1. Which song is present in the highest number of Spotify playlists?

SELECT 
    track_name, 
    artist_name, 
    in_spotify_playlists
FROM 
    spotify
ORDER BY 
    in_spotify_playlists DESC
LIMIT 1;

#2. Is there a correlation between the number of streams and a song's presence in Spotify charts?

SELECT   ROUND((
           COUNT(*) * SUM(streams * in_spotify_charts) -
           SUM(streams) * SUM(in_spotify_charts)
         ) /
         SQRT(
           (COUNT(*) * SUM(streams * streams) - (SUM(streams) * SUM(streams))) *
           (COUNT(*) * SUM(in_spotify_charts * in_spotify_charts) - (SUM(in_spotify_charts) * SUM(in_spotify_charts)))
         ), 4) AS correlation_coeff
FROM     spotify;

# 3. What is the average BPM (Beats Per Minute) of songs on Spotify?

SELECT AVG(bpm) as average_bpm
FROM   spotify;

#4. What is the average danceability of the top 15 most popular songs?

SELECT AVG(danceability) AS avg_danceability
FROM (
    SELECT danceability
    FROM spotify
    ORDER BY streams DESC
    LIMIT 15
) AS top_15_songs;


### `C. Apple Music Metrics`:

#1. How many songs made it to both Apple Music charts and Spotify charts?

SELECT SUM(CASE WHEN in_spotify_charts IS NOT NULL AND in_apple_charts IS NOT NULL THEN 1 ELSE 0 END) AS      common_songs_count
FROM   spotify;

# 2. Do songs in Apple Music playlists have higher valence percentages on average?

SELECT 
    AVG(CASE WHEN in_apple_playlists > 0 THEN valence ELSE NULL END) AS avg_valence_in_apple,
    AVG(CASE WHEN in_apple_playlists = 0 THEN valence ELSE NULL END) AS avg_valence_not_in_apple
FROM spotify;


### `D. Deezer Metrics`:

#1. Are there any trends in the presence of songs on Deezer charts based on the release month?

SELECT   released_month,
         COUNT(*) AS songs_count
FROM     spotify
WHERE    in_deezer_charts IS NOT NULL
GROUP BY 1
ORDER BY 1;

# 2. How many songs are common between Deezer and Spotify playlists?

SELECT SUM(CASE WHEN in_spotify_playlists IS NOT NULL AND in_deezer_playlists IS NOT NULL THEN 1 ELSE 0 END) AS common_songs_count
FROM   spotify;


### `E. Shazam Metrics`:

# 1. Do songs that perform well on Shazam charts have higher danceability percentages? _(not sure about the solution)_

SELECT 
    AVG(CASE WHEN in_shazam_charts > 0 THEN danceability ELSE NULL END) AS avg_danceability_on_shazam,
    AVG(CASE WHEN in_shazam_charts = 0 THEN danceability ELSE NULL END) AS avg_danceability_not_on_shazam
FROM spotify;

# 2. What is the distribution of speechiness percentages for songs on Shazam charts?

SELECT   CONCAT(FLOOR(`speechiness_%` / 5) * 5, '-', FLOOR(`speechiness_%` / 5) * 5 + 5) AS speechiness_distribution,
         COUNT(*) AS songs_count
FROM     spotify
WHERE    in_shazam_charts IS NOT NULL
GROUP BY 1
ORDER BY 1;


### `F. Audio Features`:

# 1. Is there a noticeable difference in danceability percentages between songs in major and minor modes?

SELECT   DISTINCT mode, AVG(`danceability_%`) as avg_danceability
FROM     spotify
GROUP BY 1;

#2. How does the distribution of acousticness percentages vary across different keys?

SELECT DISTINCT spotify.key, AVG(`acousticness_%`) AS avg_acousticness
FROM spotify
GROUP BY 1
ORDER BY 1;

#3. Are there any trends in the energy levels of songs over the years?

SELECT   CONCAT(FLOOR(released_year / 10) * 10, '-', FLOOR(released_year / 10) * 10 + 10) AS decade_range,
         ROUND(AVG(`energy_%`), 2) as avg_energy
FROM     spotify
GROUP BY 1
ORDER BY 1;

#4. What are the most common song keys for the entire dataset?

SELECT   `key`, COUNT(*) as songs_count
FROM     spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT    5;


### `G. Artist Impact`:

#1. What is the average number of artists contributing to a song that makes it to the charts?

SELECT AVG(artist_count) as avg_artist_count
FROM   spotify
WHERE  track_name IN (in_spotify_charts, in_apple_charts, in_deezer_charts, in_shazam_charts);

#2. Do songs with a higher number of artists tend to have higher or lower danceability percentages?

SELECT 
    artist_count,
    AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY artist_count
ORDER BY artist_count;


### `H. Temporal Trends`:

# 1. How has the distribution of song valence percentages changed over the months in 2023?

SELECT   released_month, AVG(`valence_%`) AS avg_valence
FROM     spotify
WHERE    released_year='2023'
GROUP BY 1
ORDER BY 1;

#2. Are there any noticeable trends in the key of songs over the years?

SELECT    CONCAT(FLOOR(released_year / 5) * 5, '-', FLOOR(released_year / 5) * 5 + 4) AS five_year_range,
          SUBSTRING_INDEX(GROUP_CONCAT(`key` ORDER BY key_count DESC), ',', 1) AS most_common_key
FROM (
          SELECT released_year,
                `key`,
                COUNT(*) AS key_count
          FROM spotify
          GROUP BY released_year, `key`
         ) AS key_counts
GROUP BY 1
ORDER BY 1;


### `I. Correlation Analysis`:

#1. Is there a correlation between BPM and danceability percentages?

SELECT bpm, danceability
FROM spotify
WHERE bpm IS NOT NULL AND danceability IS NOT NULL;

#2. How does the presence of live performance elements (liveness) correlate with acousticness percentages?

SELECT   ROUND((
           COUNT(*) * SUM(`liveness_%` * `acousticness_%`) -
           SUM(`liveness_%`) * SUM(`acousticness_%`)
         ) /
         SQRT(
           (COUNT(*) * SUM(`liveness_%` * `liveness_%`) - (SUM(`liveness_%`) * SUM(`liveness_%`))) *
           (COUNT(*) * SUM(`acousticness_%` * `acousticness_%`) - (SUM(`acousticness_%`) * SUM(`acousticness_%`)))
         ), 4) AS correlation_coeff
FROM     spotify;

### `J. Popularity Analysis`:

#1. Do songs with higher valence percentages tend to have more streams on Spotify?

SELECT
    (SUM(valence_% * streams) - SUM(valence_%) * SUM(streams) / COUNT(*)) / 
    SQRT((SUM(valence_% * valence_%) - POW(SUM(valence_%), 2) / COUNT(*)) * 
    (SUM(streams * streams) - POW(SUM(streams), 2) / COUNT(*))) AS valence_streams_correlation
FROM spotify;

# 2. Is there a relationship between the number of Spotify playlists and the presence on Apple Music charts?

SELECT
    (SUM(in_spotify_playlists * in_apple_charts) - SUM(in_spotify_playlists) * SUM(in_apple_charts) / COUNT(*)) / 
    SQRT((SUM(in_spotify_playlists * in_spotify_playlists) - POW(SUM(in_spotify_playlists), 2) / COUNT(*)) * 
    (SUM(in_apple_charts * in_apple_charts) - POW(SUM(in_apple_charts), 2) / COUNT(*))) AS correlation
FROM spotify;


### `K. Miscellaneous`:

#1. What is the distribution of key and mode combinations across the dataset?

SELECT 
    `key`, 
    mode, 
    COUNT(*) AS count_of_songs
FROM spotify_2023
GROUP BY `key`, mode
ORDER BY `key`, mode;

SELECT   CONCAT(`key`, '-', `mode`) AS key_mode_combination,
         COUNT(*) AS total_count
FROM     spotify
GROUP BY 1
ORDER BY 2 DESC;

#2. Are there any patterns in the release days of songs that make it to the charts?

SELECT   released_day, COUNT(*) AS songs_count
FROM     spotify
WHERE    in_spotify_charts = 1 
          OR in_apple_charts = 1 
          OR in_deezer_charts = 1 
          OR in_shazam_charts = 1
GROUP BY released_day
ORDER BY released_day;

#3. How do instrumentalness percentages correlate with energy levels?

SELECT 
    AVG(instrumentalness) AS avg_instrumentalness,
    AVG(energy) AS avg_energy,
    COUNT(*) AS track_count
FROM 
    spotify;


