-- ============================================================
-- BIG DATA PROJECT: SOCIAL MEDIA ANALYTICS & CLEANING 
-- ============================================================

-- STEP 1: CREATE RAW TABLES (Loading Data from HDFS)

 --1. YouTube Raw Table
CREATE TABLE IF NOT EXISTS youtube_raw (
    video_id STRING,
    title STRING,
    channel_title STRING,
    category_id INT,
    views BIGINT,
    likes BIGINT,
    dislikes BIGINT,
    comment_count BIGINT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

 --2. Facebook Raw Table
CREATE TABLE IF NOT EXISTS facebook_raw (
    userid BIGINT,
    age INT,
    dob_day INT,
    dob_year INT,
    dob_month INT,
    gender STRING,
    tenure INT,
    friend_count INT,
    friendships_initiated INT,
    likes INT,
    likes_received INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

 --3. Instagram Raw Table
CREATE TABLE IF NOT EXISTS instagram_raw (
    post_id STRING,
    account_type STRING,
    media_type STRING,
    likes INT,
    comments INT,
    shares INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- STEP 2: DATA CLEANING & FILTERING

 --1. Cleaned YouTube Table
CREATE TABLE youtube_cleaned AS
SELECT * FROM youtube_raw
WHERE views IS NOT NULL AND views >= 0 AND likes IS NOT NULL;

 --2. Cleaned Facebook Table
CREATE TABLE facebook_cleaned AS
SELECT * FROM facebook_raw
WHERE age IS NOT NULL AND age > 0 AND gender IS NOT NULL;

 --3. Cleaned Instagram Table
CREATE TABLE instagram_cleaned AS
SELECT * FROM instagram_raw
WHERE likes IS NOT NULL AND likes >= 0;


-- STEP 3: ANALYTICAL QUERIES FOR POWER BI DASHBOARD

 --Query 1: High-Level KPI Summary (YouTube Totals)
SELECT 
    'KPIs Summary' AS metric_type,
    SUM(views) AS total_youtube_views,
    SUM(likes) AS total_youtube_likes,
    COUNT(*) AS total_youtube_videos
FROM youtube_cleaned;

 --Query 2: Cross-Platform Performance Comparison
SELECT 
    'YouTube' AS platform,
    COUNT(*) AS total_posts,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes
FROM youtube_cleaned
UNION ALL
SELECT 
    'Instagram' AS platform,
    COUNT(*) AS total_posts,
    0 AS total_views,
    SUM(likes) AS total_likes
FROM instagram_cleaned
UNION ALL
SELECT 
    'Facebook' AS platform,
    COUNT(*) AS total_posts,
    0 AS total_views,
    SUM(likes) AS total_likes
FROM facebook_cleaned;

 --Query 3: Facebook Demographics Analysis (Age Groups & Gender)
SELECT 
    gender,
    CASE 
        WHEN age < 20 THEN '13-19 (Teens)'
        WHEN age BETWEEN 20 AND 30 THEN '20-30 (Young Adults)'
        WHEN age BETWEEN 31 AND 50 THEN '31-50 (Adults)'
        ELSE '51+ (Seniors)'
    END AS age_group,
    COUNT(*) AS user_count,
    ROUND(AVG(likes), 0) AS avg_likes
FROM facebook_cleaned
GROUP BY 
    gender,
    CASE 
        WHEN age < 20 THEN '13-19 (Teens)'
        WHEN age BETWEEN 20 AND 30 THEN '20-30 (Young Adults)'
        WHEN age BETWEEN 31 AND 50 THEN '31-50 (Adults)'
        ELSE '51+ (Seniors)'
    END;

 --Query 4: Top 10 Performing Channels on YouTube
SELECT 
    channel_title,
    COUNT(*) AS total_videos,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes
FROM youtube_cleaned
GROUP BY channel_title
ORDER BY total_views DESC
LIMIT 10;

 --Query 5: YouTube Channels Engagement Rate Percentage
SELECT 
    channel_title,
    ROUND(SUM(likes) / SUM(views) * 100, 2) AS engagement_rate_pct
FROM youtube_cleaned
GROUP BY channel_title
HAVING SUM(views) > 10000000
ORDER BY engagement_rate_pct DESC
LIMIT 5;

 --Query 6: Instagram Media and Account Performance
SELECT 
    account_type,
    SUM(likes) AS total_likes,
    SUM(comments) AS total_comments,
    SUM(shares) AS total_shares
FROM instagram_cleaned
GROUP BY account_type;
