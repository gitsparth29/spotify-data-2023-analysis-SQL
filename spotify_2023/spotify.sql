create database spotify_tracks;
use spotify_tracks;

CREATE TABLE spotify_2023 (
    track_name VARCHAR(255),
    artist_name VARCHAR(255),
    artist_count INT,
    released_year INT,
    released_month INT,
    released_day INT,
    in_spotify_playlists INT,
    in_spotify_charts INT,
    streams BIGINT,
    in_apple_playlists INT,
    in_apple_charts INT,
    in_deezer_playlists INT,
    in_deezer_charts INT,
    in_shazam_charts INT,
    bpm INT,
    `key` VARCHAR(10),  -- `key` is enclosed in backticks
    mode VARCHAR(10),
    danceability DECIMAL(5,2),
    valence DECIMAL(5,2),
    energy DECIMAL(5,2),
    acousticness DECIMAL(5,2),
    instrumentalness DECIMAL(5,2),
    liveness DECIMAL(5,2),
    speechiness DECIMAL(5,2)
);

ALTER TABLE spotify_2023 RENAME TO spotify;

select * from spotify;
