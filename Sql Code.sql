CREATE SCHEMA SPOTIFY_DATASET;

USE SPOTIFY_DATASET;

CREATE TABLE SPOTIFY_HISTORY (spotify_track_uri TEXT,	ts TEXT,	platform TEXT, 	ms_played TEXT,	track_name TEXT,	
artist_name TEXT,	album_name TEXT,	reason_start TEXT,	reason_end TEXT, 	shuffle TEXT,	skipped TEXT);

SELECT * FROM SPOTIFY_HISTORY;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Spotify Dataset\\SPOTIFY_HISTORY.CSV' 
INTO TABLE SPOTIFY_HISTORY	
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# LOAD DATA INFILE 'PATH OF CSV' 
# INTO TABLE TABLE_NAME
# FIELDS TERMINATED BY ','
# ENCLOSED BY '"'
# LINES TERMINATED BY '\n'
# IGNORE 1 ROWS;

SELECT * FROM SPOTIFY_HISTORY;

# DROP DATABASE spotify_dataset;

select * from spotify_history;


						## EDA(EXPOLRATORY DATA ANALYSIS)
select count(*) from spotify_history;
select distinct * from spotify_history;
		#1) Spotify_Track_uri
SELECT SPOTIFY_TRACK_URI FROM SPOTIFY_HISTORY WHERE SPOTIFY_TRACK_URI=NULL;
select count(spotify_track_uri) from spotify_History where spotify_track_uri="";  # no null values
select distinct spotify_track_uri, count(spotify_track_uri) 'Frequency' from spotify_history group by spotify_track_uri;

		#2) Spotify_History
SELECT ts FROM SPOTIFY_HISTORY WHERE ts=NULL;
select count(ts) from spotify_history where ts="";
select count(ts) from spotify_history where ts=" ";
alter table spotify_history modify column ts datetime;
desc spotify_history;
select ts from spotify_history;


		#3) Platform
select count(platform) from spotify_history where platform=null;
select count(platform) from spotify_history where platform=" ";
select count(platform) from spotify_history where platform="";
select distinct platform from spotify_history;
select distinct platform, count(platform) 'Frequency' from spotify_history group by platform;


		#4)ms_played
select ms_played from spotify_history;
alter table spotify_history 
	modify column ms_played int;
select count(ms_played) from spotify_history where ms_played="";
select count(ms_played) from spotify_history where ms_played=" ";
select ms_played from spotify_history where ms_played=" ";
select count(ms_played) from spotify_history where ms_played=null;
select ms_played from spotify_history;
select distinct ms_played from spotify_history;
select distinct ms_played, count(ms_played) 'frequency' from spotify_history group by ms_played;


		#5)track_name
select count(track_name) from spotify_history where track_name=null;
select count(track_name) from spotify_history where track_name="";
select count(track_name) from spotify_history where track_name=" ";
select distinct track_name from spotify_history;
select distinct track_name, count(track_name) 'frequency' from spotify_history group by track_name order by frequency desc;


		#6)artist_name
select count(artist_name) from spotify_history where artist_name=null;
select count(artist_name) from spotify_history where artist_name="";
select count(artist_name) from spotify_history where artist_name=" ";
select distinct artist_name from spotify_history;
select distinct artist_name, count(artist_name) 'frequency' from spotify_history group by artist_name order by frequency desc;

		#7)reason_start
select count(reason_start) from spotify_history where reason_start="";
select count(reason_start) from spotify_history where reason_start=null;
select distinct reason_start from spotify_history;
select * from spotify_history where reason_start="";	
update spotify_history set reason_start="No Reason Provided" where reason_start="" ;

		#8)reason_end 
select reason_end from spotify_history;
select distinct reason_end from spotify_history;
select distinct reason_end, count(reason_end) 'frequency' from spotify_history group by reason_end order by frequency desc;
update spotify_history set reason_end="No Reason Provided" where reason_end="";

		#9)Shuffle
select shuffle from spotify_history;
select distinct shuffle from spotify_history;
select distinct shuffle, count(shuffle) 'frequency'from spotify_history group by shuffle;

		#10)Skipped  
select skipped from spotify_history;
select distinct skipped from spotify_history;
select distinct skipped, count(skipped) 'frequency' from spotify_history group by skipped;



						## Problem Statement
#1)1. Top Artists & Songs:
#o Which artists were most listened to this year?
#o How does that compare to last year?
#o What are the most-played songs overall?


#Which artists were most listened to this year?
select * from spotify_history;
SELECT artist_name,COUNT(*) AS total_plays,SUM(ms_played) / 3600000 AS total_hours_played FROM spotify_history WHERE YEAR(ts) = 2024 GROUP BY artist_name
ORDER BY total_hours_played DESC LIMIT 10;

-- How does that compare to last year 
select * from spotify_history;
SELECT artist_name,COUNT(*) AS total_plays,SUM(ms_played) / 3600000 AS total_hours_played FROM spotify_history WHERE YEAR(ts) = 2024 GROUP BY artist_name
ORDER BY total_hours_played DESC LIMIT 10;

select * from spotify_history;
SELECT artist_name,COUNT(*) AS total_plays,SUM(ms_played) / 3600000 AS total_hours_played FROM spotify_history WHERE YEAR(ts) = 2024-1 GROUP BY artist_name
ORDER BY total_hours_played DESC LIMIT 10;

-- What are the most-played songs overall?
SELECT track_name, artist_name,COUNT(*) AS total_plays,SUM(ms_played) / 3600000 AS total_hours_played
FROM spotify_history GROUP BY track_name, artist_name ORDER BY total_hours_played DESC
LIMIT 10;


#2)Skipping Behavior:
#o Which songs are most frequently skipped?
#o Are favorite songs also being skipped sometimes?

-- Which songs are most frequently skipped?
select * from spotify_history;

SELECT 
  track_name,
  artist_name,
  COUNT(*) AS skipped_count,
  AVG(ms_played) / 1000 AS avg_seconds_before_skip
FROM spotify_history
WHERE skipped = TRUE  -- Filter for skipped tracks
GROUP BY track_name, artist_name
ORDER BY skipped_count DESC
LIMIT 10;


-- Compare total plays vs. skips for "favorite" (most-played) songs
WITH FavoriteSongs AS (
  SELECT 
    track_name,
    artist_name,
    COUNT(*) AS total_plays
  FROM spotify_history
  GROUP BY track_name, artist_name
  ORDER BY total_plays DESC
  LIMIT 100  -- Define "favorites" as top 100 most-played songs
)
SELECT 
  f.track_name,
  f.artist_name,
  f.total_plays,
  COUNT(s.track_name) AS skipped_plays,
  ROUND((COUNT(s.track_name) * 100.0 / f.total_plays), 2) AS skip_rate_percent
FROM FavoriteSongs f
LEFT JOIN spotify_history s 
  ON f.track_name = s.track_name 
  AND f.artist_name = s.artist_name 
  AND s.skipped = TRUE  -- Join skipped instances
GROUP BY f.track_name, f.artist_name, f.total_plays
ORDER BY f.total_plays DESC;


-- 3)Listening Time Analysis:
-- o What are the most common times of day or days of the week for music streaming?
-- o Identify any clear trends in listening behavior (e.g., late-night listening, weekend bingeing).

-- Hourly Listening Patterns
SELECT 
  HOUR(ts) AS hour_of_day,
  DAYNAME(ts) AS day_of_week,
  SUM(ms_played) / 3600000 AS hours_played
FROM spotify_history
GROUP BY hour_of_day, day_of_week
ORDER BY hours_played DESC;

-- Simplified Version (Hourly Aggregates)
SELECT 
  HOUR(ts) AS hour_of_day,
  SUM(ms_played) / 3600000 AS hours_played
FROM spotify_history
GROUP BY hour_of_day
ORDER BY hours_played DESC;


SELECT 
  DAYNAME(ts) AS day_of_week,
  SUM(ms_played) / 3600000 AS hours_played
FROM spotify_history
GROUP BY day_of_week
ORDER BY hours_played DESC;

-- Late-Night (12 AM - 5 AM) vs. Daytime Listening
SELECT 
  CASE 
    WHEN HOUR(ts) BETWEEN 0 AND 5 THEN 'Late Night (12 AM - 5 AM)'
    ELSE 'Daytime'
  END AS time_category,
  SUM(ms_played) / 3600000 AS hours_played
FROM spotify_history
GROUP BY time_category;

SELECT 
  CASE 
    WHEN DAYOFWEEK(ts) IN (1, 7) THEN 'Weekend'  -- 1 = Sunday, 7 = Saturday
    ELSE 'Weekday'
  END AS day_type,
  SUM(ms_played) / 3600000 AS hours_played
FROM spotify_history
GROUP BY day_type;

-- Discovery vs. Loyalty:
#o How often does the user listen to new artists vs. repeating familiar ones?
#o Can you identify patterns of exploration vs. routine?

WITH FirstListen AS (
  SELECT 
    artist_name,
    MIN(ts) AS first_listen_date
  FROM spotify_history
  GROUP BY artist_name
)
SELECT 
  CASE 
    WHEN f.first_listen_date = h.ts THEN 'New Artist'
    ELSE 'Repeat Artist'
  END AS listen_type,
  COUNT(*) AS total_plays,
  COUNT(DISTINCT h.artist_name) AS unique_artists
FROM spotify_history h
JOIN FirstListen f ON h.artist_name = f.artist_name
GROUP BY listen_type;

WITH ArtistFirstPlay AS (
  SELECT 
    artist_name,
    MIN(DATE(ts)) AS first_play_date
  FROM spotify_history
  GROUP BY artist_name
),
MonthlySummary AS (
  SELECT 
    DATE_FORMAT(h.ts, '%Y-%m') AS month,
    COUNT(*) AS total_plays,
    COUNT(DISTINCT CASE WHEN DATE(h.ts) = a.first_play_date THEN h.artist_name END) AS new_artists
  FROM spotify_history h
  LEFT JOIN ArtistFirstPlay a ON h.artist_name = a.artist_name
  GROUP BY month
)
SELECT 
  month,
  total_plays,
  new_artists,
  ROUND((new_artists * 100.0 / total_plays), 2) AS exploration_rate_percent
FROM MonthlySummary
ORDER BY month;



 