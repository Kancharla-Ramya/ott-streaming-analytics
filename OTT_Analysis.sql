/* ============================================================
   NIIT FINAL CAPSTONE PROJECT
   OTT STREAMING PLATFORM VIEWING PATTERN ANALYSIS

   Topic:
   Analyse OTT Platform Viewing Patterns to Support
   Data-Driven Content Decisions (MediaTech)

   Database: MySQL

   Tables:
   1. user_profile
   2. content_info
   3. viewing_activity
   4. subscription_retention
   5. ratings_feedback
   ============================================================ */


/* ============================================================
   SECTION 1: DATABASE AND TABLE OVERVIEW
   ============================================================ */

USE ott_analysis;

SHOW TABLES;

DESCRIBE user_profile;
DESCRIBE content_info;
DESCRIBE viewing_activity;
DESCRIBE subscription_retention;
DESCRIBE ratings_feedback;


/* ============================================================
   SECTION 2: DATA UNDERSTANDING
   ============================================================ */

-- Total records in each table

SELECT COUNT(*) AS total_users
FROM user_profile;

SELECT COUNT(*) AS total_content
FROM content_info;

SELECT COUNT(*) AS total_viewing_records
FROM viewing_activity;

SELECT COUNT(*) AS total_subscriptions
FROM subscription_retention;

SELECT COUNT(*) AS total_ratings_feedback
FROM ratings_feedback;


-- Sample records

SELECT *
FROM user_profile
LIMIT 10;

SELECT *
FROM content_info
LIMIT 10;

SELECT *
FROM viewing_activity
LIMIT 10;

SELECT *
FROM subscription_retention
LIMIT 10;

SELECT *
FROM ratings_feedback
LIMIT 10;


/* ============================================================
   SECTION 3: DATA QUALITY CHECKS
   ============================================================ */

-- Missing values in important columns

SELECT
    SUM(User_ID IS NULL) AS missing_user_id,
    SUM(Gender IS NULL) AS missing_gender,
    SUM(Age_Group IS NULL) AS missing_age_group,
    SUM(Region IS NULL) AS missing_region,
    SUM(Subscription_Type IS NULL) AS missing_subscription_type,
    SUM(Device_Type IS NULL) AS missing_device_type
FROM user_profile;


SELECT
    SUM(Content_ID IS NULL) AS missing_content_id,
    SUM(Title IS NULL) AS missing_title,
    SUM(Content_Type IS NULL) AS missing_content_type,
    SUM(Platform IS NULL) AS missing_platform,
    SUM(Duration_Minutes IS NULL) AS missing_duration,
    SUM(Numeric_Rating IS NULL) AS missing_rating
FROM content_info;


SELECT
    SUM(Viewing_Record_ID IS NULL) AS missing_viewing_record_id,
    SUM(User_ID IS NULL) AS missing_user_id,
    SUM(Content_ID IS NULL) AS missing_content_id,
    SUM(View_Date IS NULL) AS missing_view_date,
    SUM(Watch_Duration_Minutes IS NULL) AS missing_watch_duration,
    SUM(Completion_Percentage IS NULL) AS missing_completion
FROM viewing_activity;


SELECT
    SUM(User_ID IS NULL) AS missing_user_id,
    SUM(Monthly_Fee IS NULL) AS missing_monthly_fee,
    SUM(Renewal_Status IS NULL) AS missing_renewal_status,
    SUM(Churn_Flag IS NULL) AS missing_churn_flag
FROM subscription_retention;


SELECT
    SUM(User_ID IS NULL) AS missing_user_id,
    SUM(Content_ID IS NULL) AS missing_content_id,
    SUM(Rating IS NULL) AS missing_rating,
    SUM(Liked_Flag IS NULL) AS missing_like,
    SUM(Feedback_Category IS NULL) AS missing_feedback
FROM ratings_feedback;


/* ============================================================
   SECTION 4: DUPLICATE CHECKS
   ============================================================ */

-- User_ID should be unique in user_profile

SELECT
    User_ID,
    COUNT(*) AS duplicate_count
FROM user_profile
GROUP BY User_ID
HAVING COUNT(*) > 1;


-- Content_ID should be unique in content_info

SELECT
    Content_ID,
    COUNT(*) AS duplicate_count
FROM content_info
GROUP BY Content_ID
HAVING COUNT(*) > 1;


-- Viewing_Record_ID is the unique identifier for viewing_activity

SELECT
    Viewing_Record_ID,
    COUNT(*) AS duplicate_count
FROM viewing_activity
GROUP BY Viewing_Record_ID
HAVING COUNT(*) > 1;


-- User_ID should be unique in subscription_retention

SELECT
    User_ID,
    COUNT(*) AS duplicate_count
FROM subscription_retention
GROUP BY User_ID
HAVING COUNT(*) > 1;


-- User + Content combination in ratings_feedback

SELECT
    User_ID,
    Content_ID,
    COUNT(*) AS duplicate_count
FROM ratings_feedback
GROUP BY User_ID, Content_ID
HAVING COUNT(*) > 1;


/* ============================================================
   SECTION 5: REFERENTIAL INTEGRITY
   ============================================================ */

-- Users in viewing_activity that do not exist in user_profile

SELECT COUNT(*) AS invalid_viewing_users
FROM viewing_activity v
LEFT JOIN user_profile u
    ON v.User_ID = u.User_ID
WHERE u.User_ID IS NULL;


-- Content in viewing_activity that do not exist in content_info

SELECT COUNT(*) AS invalid_viewing_content
FROM viewing_activity v
LEFT JOIN content_info c
    ON v.Content_ID = c.Content_ID
WHERE c.Content_ID IS NULL;


-- Users in ratings_feedback that do not exist in user_profile

SELECT COUNT(*) AS invalid_rating_users
FROM ratings_feedback r
LEFT JOIN user_profile u
    ON r.User_ID = u.User_ID
WHERE u.User_ID IS NULL;


-- Content in ratings_feedback that do not exist in content_info

SELECT COUNT(*) AS invalid_rating_content
FROM ratings_feedback r
LEFT JOIN content_info c
    ON r.Content_ID = c.Content_ID
WHERE c.Content_ID IS NULL;


-- Users in subscription_retention that do not exist
-- in user_profile

SELECT COUNT(*) AS invalid_subscription_users
FROM subscription_retention sr
LEFT JOIN user_profile u
    ON sr.User_ID = u.User_ID
WHERE u.User_ID IS NULL;


-- Users in user_profile without subscription records

SELECT COUNT(*) AS users_without_subscription
FROM user_profile u
LEFT JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID
WHERE sr.User_ID IS NULL;


-- Check consistency of Subscription_Type between
-- user_profile and subscription_retention

SELECT
    u.User_ID,
    u.Subscription_Type AS profile_subscription_type,
    sr.Subscription_Type AS retention_subscription_type
FROM user_profile u
JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID
WHERE u.Subscription_Type <> sr.Subscription_Type;


/* ============================================================
   SECTION 6: RANGE AND VALIDATION CHECKS
   ============================================================ */

-- Invalid ratings

SELECT *
FROM ratings_feedback
WHERE Rating < 1
   OR Rating > 5;


-- Invalid completion percentages

SELECT *
FROM viewing_activity
WHERE Completion_Percentage < 0
   OR Completion_Percentage > 100;


-- Invalid watch duration

SELECT *
FROM viewing_activity
WHERE Watch_Duration_Minutes < 0;


-- Invalid churn flag

SELECT *
FROM subscription_retention
WHERE Churn_Flag NOT IN (0,1);


/* ============================================================
   SECTION 7: DESCRIPTIVE STATISTICS
   ============================================================ */

-- Watch duration statistics

SELECT
    COUNT(*) AS total_records,
    ROUND(AVG(Watch_Duration_Minutes),2)
        AS average_watch_duration,
    ROUND(MIN(Watch_Duration_Minutes),2)
        AS minimum_watch_duration,
    ROUND(MAX(Watch_Duration_Minutes),2)
        AS maximum_watch_duration,
    ROUND(STDDEV(Watch_Duration_Minutes),2)
        AS standard_deviation
FROM viewing_activity;


-- Completion statistics

SELECT
    COUNT(*) AS total_records,
    ROUND(AVG(Completion_Percentage),2)
        AS average_completion,
    MIN(Completion_Percentage)
        AS minimum_completion,
    MAX(Completion_Percentage)
        AS maximum_completion
FROM viewing_activity;


-- Rating statistics

SELECT
    COUNT(*) AS total_ratings,
    ROUND(AVG(Rating),2)
        AS average_rating,
    MIN(Rating)
        AS minimum_rating,
    MAX(Rating)
        AS maximum_rating
FROM ratings_feedback;


-- Monthly fee statistics

SELECT
    ROUND(AVG(Monthly_Fee),2)
        AS average_monthly_fee,
    MIN(Monthly_Fee)
        AS minimum_monthly_fee,
    MAX(Monthly_Fee)
        AS maximum_monthly_fee
FROM subscription_retention;


/* ============================================================
   SECTION 8: MEDIAN WATCH DURATION
   ============================================================ */

WITH ranked_data AS
(
    SELECT
        Watch_Duration_Minutes,

        ROW_NUMBER() OVER
        (
            ORDER BY Watch_Duration_Minutes
        ) AS row_num,

        COUNT(*) OVER () AS total_rows

    FROM viewing_activity
)

SELECT
    ROUND(AVG(Watch_Duration_Minutes),2)
        AS median_watch_duration

FROM ranked_data

WHERE row_num IN
(
    FLOOR((total_rows + 1) / 2),
    CEIL((total_rows + 1) / 2)
);


/* ============================================================
   SECTION 9: UNIVARIATE ANALYSIS
   ============================================================ */

-- Gender distribution

SELECT
    Gender,
    COUNT(*) AS users
FROM user_profile
GROUP BY Gender
ORDER BY users DESC;


-- Age group distribution

SELECT
    Age_Group,
    COUNT(*) AS users
FROM user_profile
GROUP BY Age_Group
ORDER BY users DESC;


-- Region distribution

SELECT
    Region,
    COUNT(*) AS users
FROM user_profile
GROUP BY Region
ORDER BY users DESC;


-- Subscription type distribution

SELECT
    Subscription_Type,
    COUNT(*) AS users
FROM user_profile
GROUP BY Subscription_Type
ORDER BY users DESC;


-- Device distribution

SELECT
    Device_Type,
    COUNT(*) AS users
FROM user_profile
GROUP BY Device_Type
ORDER BY users DESC;


-- Content type distribution

SELECT
    Content_Type,
    COUNT(*) AS content_count
FROM content_info
GROUP BY Content_Type
ORDER BY content_count DESC;


-- Platform distribution

SELECT
    Platform,
    COUNT(*) AS content_count
FROM content_info
GROUP BY Platform
ORDER BY content_count DESC;


-- Feedback distribution

SELECT
    Feedback_Category,
    COUNT(*) AS feedback_count
FROM ratings_feedback
GROUP BY Feedback_Category
ORDER BY feedback_count DESC;


/* ============================================================
   SECTION 10: BIVARIATE ANALYSIS
   ============================================================ */

-- Subscription type vs churn

SELECT
    sr.Subscription_Type,
    COUNT(*) AS total_users,
    SUM(sr.Churn_Flag) AS churned_users,
    ROUND(
        AVG(sr.Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage
FROM subscription_retention sr
GROUP BY sr.Subscription_Type
ORDER BY churn_rate_percentage DESC;


-- Subscription type vs renewal

SELECT
    Subscription_Type,
    COUNT(*) AS total_users,
    SUM(Renewal_Status = 'Renewed')
        AS renewed_users,
    ROUND(
        AVG(Renewal_Status = 'Renewed') * 100,
        2
    ) AS renewal_rate_percentage
FROM subscription_retention
GROUP BY Subscription_Type
ORDER BY renewal_rate_percentage DESC;


-- Age group vs churn

SELECT
    u.Age_Group,
    COUNT(*) AS total_users,
    SUM(sr.Churn_Flag) AS churned_users,
    ROUND(
        AVG(sr.Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage
FROM user_profile u
JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID
GROUP BY u.Age_Group
ORDER BY churn_rate_percentage DESC;


-- Region vs churn

SELECT
    u.Region,
    COUNT(*) AS total_users,
    SUM(sr.Churn_Flag) AS churned_users,
    ROUND(
        AVG(sr.Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage
FROM user_profile u
JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID
GROUP BY u.Region
ORDER BY churn_rate_percentage DESC;


-- Engagement level vs churn

SELECT
    u.Engagement_Level,
    COUNT(*) AS total_users,
    SUM(sr.Churn_Flag) AS churned_users,
    ROUND(
        AVG(sr.Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage
FROM user_profile u
JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID
GROUP BY u.Engagement_Level
ORDER BY churn_rate_percentage DESC;


-- Device vs average completion

SELECT
    Device_Type,
    COUNT(*) AS viewing_records,
    ROUND(
        AVG(Completion_Percentage),
        2
    ) AS average_completion
FROM viewing_activity
GROUP BY Device_Type
ORDER BY average_completion DESC;


-- Time of day vs average completion

SELECT
    Time_of_Day,
    COUNT(*) AS viewing_records,
    ROUND(
        AVG(Completion_Percentage),
        2
    ) AS average_completion
FROM viewing_activity
GROUP BY Time_of_Day
ORDER BY average_completion DESC;


-- Platform vs viewing performance

SELECT
    c.Platform,
    COUNT(v.Viewing_Record_ID) AS total_views,
    ROUND(
        AVG(v.Completion_Percentage),
        2
    ) AS average_completion,
    ROUND(
        SUM(v.Watch_Duration_Minutes) / 60,
        2
    ) AS watch_hours
FROM content_info c
JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID
GROUP BY c.Platform
ORDER BY total_views DESC;


-- Content type vs viewing performance

SELECT
    c.Content_Type,
    COUNT(v.Viewing_Record_ID) AS total_views,
    ROUND(
        SUM(v.Watch_Duration_Minutes) / 60,
        2
    ) AS watch_hours,
    ROUND(
        AVG(v.Completion_Percentage),
        2
    ) AS average_completion
FROM content_info c
JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID
GROUP BY c.Content_Type
ORDER BY watch_hours DESC;


/* ============================================================
   SECTION 11: MULTIVARIATE ANALYSIS
   ============================================================ */

-- Age + subscription type + churn

SELECT
    u.Age_Group,
    sr.Subscription_Type,
    COUNT(*) AS total_users,
    SUM(sr.Churn_Flag) AS churned_users,
    ROUND(
        AVG(sr.Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage
FROM user_profile u
JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID
GROUP BY
    u.Age_Group,
    sr.Subscription_Type
ORDER BY churn_rate_percentage DESC;


-- Subscription + engagement + churn

SELECT
    sr.Subscription_Type,
    u.Engagement_Level,
    COUNT(*) AS total_users,
    SUM(sr.Churn_Flag) AS churned_users,
    ROUND(
        AVG(sr.Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage
FROM user_profile u
JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID
GROUP BY
    sr.Subscription_Type,
    u.Engagement_Level
HAVING COUNT(*) >= 10
ORDER BY churn_rate_percentage DESC;


-- Engagement + age + region

SELECT
    u.Engagement_Level,
    u.Age_Group,
    u.Region,
    COUNT(*) AS total_users,
    SUM(sr.Churn_Flag) AS churned_users,
    ROUND(
        AVG(sr.Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage
FROM user_profile u
JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID
GROUP BY
    u.Engagement_Level,
    u.Age_Group,
    u.Region
HAVING COUNT(*) >= 10
ORDER BY churn_rate_percentage DESC;


/* ============================================================
   SECTION 12: CHURN VS VIEWING BEHAVIOUR
   ============================================================ */

SELECT
    sr.Churn_Flag,
    COUNT(DISTINCT v.User_ID) AS users,
    ROUND(
        AVG(v.Watch_Duration_Minutes),
        2
    ) AS avg_watch_duration,
    ROUND(
        AVG(v.Completion_Percentage),
        2
    ) AS avg_completion
FROM subscription_retention sr
JOIN viewing_activity v
    ON sr.User_ID = v.User_ID
GROUP BY sr.Churn_Flag;


/* ============================================================
   SECTION 13: CONTENT PERFORMANCE
   ============================================================ */

-- Most viewed content

SELECT
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform,
    COUNT(v.Viewing_Record_ID) AS total_views
FROM content_info c
JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID
GROUP BY
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform
ORDER BY total_views DESC
LIMIT 10;


-- Content generating highest watch hours

SELECT
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform,
    ROUND(
        SUM(v.Watch_Duration_Minutes) / 60,
        2
    ) AS watch_hours
FROM content_info c
JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID
GROUP BY
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform
ORDER BY watch_hours DESC
LIMIT 10;


-- Highest completion content
-- Minimum 10 views used to avoid very small samples

SELECT
    c.Content_ID,
    c.Title,
    COUNT(v.Viewing_Record_ID) AS total_views,
    ROUND(
        AVG(v.Completion_Percentage),
        2
    ) AS average_completion
FROM content_info c
JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID
GROUP BY
    c.Content_ID,
    c.Title
HAVING COUNT(v.Viewing_Record_ID) >= 10
ORDER BY
    average_completion DESC,
    total_views DESC
LIMIT 10;


/* ============================================================
   SECTION 14: GENRE ANALYSIS
   ============================================================ */

-- Genre-based viewing analysis

SELECT
    c.Genres,
    COUNT(v.Viewing_Record_ID) AS total_views,
    ROUND(
        SUM(v.Watch_Duration_Minutes) / 60,
        2
    ) AS watch_hours,
    ROUND(
        AVG(v.Completion_Percentage),
        2
    ) AS average_completion
FROM content_info c
JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID
GROUP BY c.Genres
ORDER BY total_views DESC
LIMIT 20;


/* ============================================================
   SECTION 15: RATINGS AND FEEDBACK ANALYSIS
   ============================================================ */

-- Average rating by content

SELECT
    c.Content_ID,
    c.Title,
    COUNT(r.Rating) AS rating_count,
    ROUND(
        AVG(r.Rating),
        2
    ) AS average_rating
FROM content_info c
JOIN ratings_feedback r
    ON c.Content_ID = r.Content_ID
GROUP BY
    c.Content_ID,
    c.Title
HAVING COUNT(r.Rating) >= 5
ORDER BY average_rating DESC
LIMIT 10;


-- Average rating by content type

SELECT
    c.Content_Type,
    COUNT(r.Rating) AS rating_count,
    ROUND(
        AVG(r.Rating),
        2
    ) AS average_rating
FROM content_info c
JOIN ratings_feedback r
    ON c.Content_ID = r.Content_ID
GROUP BY c.Content_Type
ORDER BY average_rating DESC;


-- Average rating by platform

SELECT
    c.Platform,
    COUNT(r.Rating) AS rating_count,
    ROUND(
        AVG(r.Rating),
        2
    ) AS average_rating
FROM content_info c
JOIN ratings_feedback r
    ON c.Content_ID = r.Content_ID
GROUP BY c.Platform
ORDER BY average_rating DESC;


-- Feedback distribution

SELECT
    Feedback_Category,
    COUNT(*) AS feedback_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM ratings_feedback),
        2
    ) AS feedback_percentage
FROM ratings_feedback
GROUP BY Feedback_Category
ORDER BY feedback_count DESC;


/* ============================================================
   SECTION 16: HIGH-DURATION SESSION ANALYSIS
   ============================================================

   IMPORTANT:
   The 225-minute threshold is a business-defined threshold.
   It is not presented as an IQR-based statistical outlier
   threshold.

   Statistical outlier analysis was performed separately
   during Python EDA.
   ============================================================ */

-- Business-defined high watch-duration records
-- Threshold = more than 225 minutes

SELECT
    COUNT(*) AS high_duration_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM viewing_activity),
        2
    ) AS high_duration_percentage
FROM viewing_activity
WHERE Watch_Duration_Minutes > 225;


-- Display high-duration records

SELECT *
FROM viewing_activity
WHERE Watch_Duration_Minutes > 225
ORDER BY Watch_Duration_Minutes DESC
LIMIT 20;


/* ============================================================
   SECTION 17: FEATURE ENGINEERING
   ============================================================ */

-- Watch duration category

SELECT
    Viewing_Record_ID,
    Watch_Duration_Minutes,
    CASE
        WHEN Watch_Duration_Minutes <= 60
            THEN 'Short'
        WHEN Watch_Duration_Minutes <= 225
            THEN 'Medium'
        ELSE 'Long'
    END AS watch_duration_category
FROM viewing_activity
LIMIT 20;


-- Completion category

SELECT
    Viewing_Record_ID,
    Completion_Percentage,
    CASE
        WHEN Completion_Percentage < 25
            THEN '0-24%'
        WHEN Completion_Percentage < 50
            THEN '25-49%'
        WHEN Completion_Percentage < 75
            THEN '50-74%'
        ELSE '75-100%'
    END AS completion_category
FROM viewing_activity
LIMIT 20;


-- Recent content flag

SELECT
    Content_ID,
    Title,
    Release_Year,
    CASE
        WHEN Release_Year >= 2020
            THEN 'Recent'
        ELSE 'Older'
    END AS content_age_category
FROM content_info
LIMIT 20;


/* ============================================================
   SECTION 18: CORRECT USER-LEVEL MASTER ANALYSIS
   ============================================================

   Viewing and ratings are aggregated separately before joining
   to prevent row multiplication.

   This preserves accurate user-level metrics.
   ============================================================ */

WITH viewing_summary AS
(
    SELECT
        User_ID,
        COUNT(*) AS total_views,
        SUM(Watch_Duration_Minutes)
            AS total_watch_minutes,
        AVG(Watch_Duration_Minutes)
            AS avg_watch_duration,
        AVG(Completion_Percentage)
            AS avg_completion
    FROM viewing_activity
    GROUP BY User_ID
),

rating_summary AS
(
    SELECT
        User_ID,
        COUNT(*) AS total_ratings,
        AVG(Rating) AS avg_rating
    FROM ratings_feedback
    GROUP BY User_ID
)

SELECT
    u.User_ID,
    u.Age_Group,
    u.Region,
    u.Subscription_Type,
    u.Device_Type,
    u.Engagement_Level,
    sr.Churn_Flag,

    COALESCE(vs.total_views,0)
        AS total_views,

    ROUND(
        COALESCE(vs.total_watch_minutes,0),
        2
    ) AS total_watch_minutes,

    ROUND(
        COALESCE(vs.avg_watch_duration,0),
        2
    ) AS avg_watch_duration,

    ROUND(
        COALESCE(vs.avg_completion,0),
        2
    ) AS avg_completion,

    COALESCE(rs.total_ratings,0)
        AS total_ratings,

    ROUND(
        COALESCE(rs.avg_rating,0),
        2
    ) AS avg_rating

FROM user_profile u

LEFT JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID

LEFT JOIN viewing_summary vs
    ON u.User_ID = vs.User_ID

LEFT JOIN rating_summary rs
    ON u.User_ID = rs.User_ID;


/* ============================================================
   SECTION 19: TEMPORARY TABLE
   ============================================================ */

DROP TEMPORARY TABLE IF EXISTS user_view_summary;

CREATE TEMPORARY TABLE user_view_summary AS

SELECT
    User_ID,
    COUNT(*) AS total_views,
    SUM(Watch_Duration_Minutes)
        AS total_watch_minutes,
    AVG(Completion_Percentage)
        AS avg_completion

FROM viewing_activity

GROUP BY User_ID;


SELECT *
FROM user_view_summary
ORDER BY total_views DESC
LIMIT 10;


/* ============================================================
   SECTION 20: VIEWS
   ============================================================ */

-- Reusable content performance view

CREATE OR REPLACE VIEW vw_content_performance AS

SELECT
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform,

    COUNT(v.Viewing_Record_ID)
        AS total_views,

    ROUND(
        SUM(v.Watch_Duration_Minutes) / 60,
        2
    ) AS watch_hours,

    ROUND(
        AVG(v.Completion_Percentage),
        2
    ) AS average_completion

FROM content_info c

LEFT JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID

GROUP BY
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform;


SELECT *
FROM vw_content_performance
ORDER BY total_views DESC
LIMIT 10;


/* ============================================================
   SECTION 21: WINDOW FUNCTIONS
   ============================================================ */

-- Rank content by views

SELECT
    Content_ID,
    Title,
    Platform,
    total_views,

    RANK() OVER
    (
        ORDER BY total_views DESC
    ) AS content_rank

FROM vw_content_performance

WHERE total_views > 0

LIMIT 20;


-- Rank content within each platform

SELECT
    Content_ID,
    Title,
    Platform,
    total_views,

    RANK() OVER
    (
        PARTITION BY Platform
        ORDER BY total_views DESC
    ) AS platform_rank

FROM vw_content_performance

WHERE total_views > 0;


/* ============================================================
   SECTION 22: MONTHLY VIEWING TREND
   ============================================================ */

SELECT
    DATE_FORMAT(View_Date,'%Y-%m')
        AS viewing_month,

    COUNT(*) AS total_views,

    ROUND(
        SUM(Watch_Duration_Minutes) / 60,
        2
    ) AS watch_hours,

    ROUND(
        AVG(Completion_Percentage),
        2
    ) AS average_completion

FROM viewing_activity

GROUP BY DATE_FORMAT(View_Date,'%Y-%m')

ORDER BY viewing_month;


/* ============================================================
   SECTION 23: MONTH-OVER-MONTH VIEWING CHANGE
   ============================================================ */

WITH monthly_views AS
(
    SELECT
        DATE_FORMAT(View_Date,'%Y-%m')
            AS viewing_month,

        COUNT(*) AS total_views

    FROM viewing_activity

    GROUP BY DATE_FORMAT(View_Date,'%Y-%m')
)

SELECT
    viewing_month,
    total_views,

    LAG(total_views) OVER
    (
        ORDER BY viewing_month
    ) AS previous_month_views,

    total_views -
        LAG(total_views) OVER
        (
            ORDER BY viewing_month
        ) AS change_from_previous_month

FROM monthly_views

ORDER BY viewing_month;


/* ============================================================
   SECTION 24: USER ENGAGEMENT ANALYSIS
   ============================================================ */

SELECT
    u.Engagement_Level,

    COUNT(DISTINCT v.User_ID)
        AS active_users,

    COUNT(v.Viewing_Record_ID)
        AS total_views,

    ROUND(
        AVG(v.Watch_Duration_Minutes),
        2
    ) AS avg_watch_duration,

    ROUND(
        AVG(v.Completion_Percentage),
        2
    ) AS avg_completion

FROM user_profile u

JOIN viewing_activity v
    ON u.User_ID = v.User_ID

GROUP BY u.Engagement_Level

ORDER BY total_views DESC;


/* ============================================================
   SECTION 25: CONTENT SATISFACTION
   ============================================================ */

SELECT
    c.Content_Type,

    ROUND(
        AVG(r.Rating),
        2
    ) AS average_rating,

    SUM(r.Liked_Flag = 'Y')
        AS likes,

    SUM(r.Liked_Flag = 'N')
        AS dislikes,

    COUNT(*) AS total_feedback

FROM content_info c

JOIN ratings_feedback r
    ON c.Content_ID = r.Content_ID

GROUP BY c.Content_Type;


/* ============================================================
   SECTION 26: CONDITIONAL AGGREGATION
   ============================================================ */

-- Churn and renewal by subscription type

SELECT
    Subscription_Type,

    COUNT(*) AS total_users,

    SUM(
        CASE
            WHEN Churn_Flag = 1
            THEN 1
            ELSE 0
        END
    ) AS churned_users,

    SUM(
        CASE
            WHEN Churn_Flag = 0
            THEN 1
            ELSE 0
        END
    ) AS retained_users,

    SUM(
        CASE
            WHEN Renewal_Status = 'Renewed'
            THEN 1
            ELSE 0
        END
    ) AS renewed_users,

    ROUND(
        AVG(Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage

FROM subscription_retention

GROUP BY Subscription_Type;


/* ============================================================
   SECTION 27: EXISTS / NOT EXISTS
   ============================================================ */

-- Users who have never watched any content

SELECT
    u.User_ID,
    u.Age_Group,
    u.Region,
    u.Subscription_Type

FROM user_profile u

WHERE NOT EXISTS
(
    SELECT 1

    FROM viewing_activity v

    WHERE v.User_ID = u.User_ID
);


-- Content that has never been watched

SELECT
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform

FROM content_info c

WHERE NOT EXISTS
(
    SELECT 1

    FROM viewing_activity v

    WHERE v.Content_ID = c.Content_ID
);


/* ============================================================
   SECTION 28: TOP 3 CONTENT PER PLATFORM
   ============================================================ */

WITH ranked_content AS
(
    SELECT
        Content_ID,
        Title,
        Platform,
        total_views,

        RANK() OVER
        (
            PARTITION BY Platform
            ORDER BY total_views DESC
        ) AS platform_rank

    FROM vw_content_performance

    WHERE total_views > 0
)

SELECT
    Content_ID,
    Title,
    Platform,
    total_views,
    platform_rank

FROM ranked_content

WHERE platform_rank <= 3

ORDER BY
    Platform,
    platform_rank;


/* ============================================================
   SECTION 29: KPI SUMMARY
   ============================================================ */

SELECT

    (SELECT COUNT(*)
     FROM user_profile)
        AS total_users,

    (SELECT COUNT(*)
     FROM viewing_activity)
        AS total_viewing_records,

    (SELECT COUNT(*)
     FROM content_info)
        AS total_content,

    (SELECT COUNT(*)
     FROM ratings_feedback)
        AS total_ratings,

    (SELECT SUM(Churn_Flag)
     FROM subscription_retention)
        AS churned_users,

    ROUND(
        (
            SELECT AVG(Churn_Flag) * 100
            FROM subscription_retention
        ),
        2
    ) AS churn_rate_percentage,

    ROUND(
        (
            SELECT AVG(Completion_Percentage)
            FROM viewing_activity
        ),
        2
    ) AS average_completion_percentage,

    ROUND(
        (
            SELECT AVG(Rating)
            FROM ratings_feedback
        ),
        2
    ) AS average_rating,

    ROUND(
        (
            SELECT SUM(Watch_Duration_Minutes) / 60
            FROM viewing_activity
        ),
        2
    ) AS total_watch_hours;


/* ============================================================
   SECTION 30: DASHBOARD-READY SUMMARY
   ============================================================

   IMPORTANT:
   Viewing and rating data are aggregated separately before
   joining to content.

   This prevents row multiplication and preserves accurate
   platform/content-level metrics.

   Completion is calculated using total completion values
   divided by total views.

   Rating is calculated using total rating values divided
   by total rating records.

   ============================================================ */

WITH viewing_summary AS
(
    SELECT
        Content_ID,

        COUNT(*) AS total_views,

        SUM(Watch_Duration_Minutes)
            AS total_watch_minutes,

        SUM(Completion_Percentage)
            AS total_completion

    FROM viewing_activity

    GROUP BY Content_ID
),

rating_summary AS
(
    SELECT
        Content_ID,

        COUNT(*) AS rating_count,

        SUM(Rating)
            AS total_rating

    FROM ratings_feedback

    GROUP BY Content_ID
)

SELECT
    c.Platform,
    c.Content_Type,

    SUM(
        COALESCE(vs.total_views,0)
    ) AS total_views,

    ROUND(
        SUM(
            COALESCE(vs.total_watch_minutes,0)
        ) / 60,
        2
    ) AS watch_hours,

    ROUND(
        SUM(
            COALESCE(vs.total_completion,0)
        )
        /
        NULLIF(
            SUM(
                COALESCE(vs.total_views,0)
            ),
            0
        ),
        2
    ) AS average_completion,

    ROUND(
        SUM(
            COALESCE(rs.total_rating,0)
        )
        /
        NULLIF(
            SUM(
                COALESCE(rs.rating_count,0)
            ),
            0
        ),
        2
    ) AS average_rating

FROM content_info c

LEFT JOIN viewing_summary vs
    ON c.Content_ID = vs.Content_ID

LEFT JOIN rating_summary rs
    ON c.Content_ID = rs.Content_ID

GROUP BY
    c.Platform,
    c.Content_Type

ORDER BY
    c.Platform,
    total_views DESC;


/* ============================================================
   SECTION 31: INDEX AND QUERY OPTIMIZATION
   ============================================================

   These indexes improve join and filtering performance.

   IMPORTANT:
   Check existing indexes before creating these.
   Run CREATE INDEX statements only once.
   Do not create duplicate indexes if an equivalent
   primary/unique/index key already exists.
   ============================================================ */

-- Check existing indexes first

SHOW INDEX FROM user_profile;

SHOW INDEX FROM content_info;

SHOW INDEX FROM viewing_activity;

SHOW INDEX FROM subscription_retention;

SHOW INDEX FROM ratings_feedback;


-- Create indexes where equivalent indexes do not already exist.

ALTER TABLE viewing_activity
MODIFY User_ID VARCHAR(50);

CREATE INDEX idx_viewing_user
ON viewing_activity(User_ID);


ALTER TABLE viewing_activity
MODIFY Content_ID VARCHAR(50);

CREATE INDEX idx_viewing_content
ON viewing_activity(Content_ID);


ALTER TABLE ratings_feedback
MODIFY User_ID VARCHAR(50);

CREATE INDEX idx_rating_user
ON ratings_feedback(User_ID);


ALTER TABLE ratings_feedback
MODIFY Content_ID VARCHAR(50);

CREATE INDEX idx_rating_content
ON ratings_feedback(Content_ID);

ALTER TABLE subscription_retention
MODIFY User_ID VARCHAR(50);

CREATE INDEX idx_subscription_user
ON subscription_retention(User_ID);


-- Check query execution plan

EXPLAIN
SELECT
    c.Platform,
    COUNT(v.Viewing_Record_ID) AS total_views

FROM content_info c

JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID

GROUP BY c.Platform;


/* ============================================================
   SECTION 32: MOVING FROM PYTHON OBSERVATIONS TO
   QUERY-DRIVEN SQL EVIDENCE
   ============================================================

   Purpose:

   Python EDA was used to identify patterns and observations.

   SQL is used to validate those observations using
   query-driven evidence.

   Example Python observations:

   - Churn rate is approximately 44.4%.
   - Free Trial users show the highest churn.
   - TV Shows generate substantially more watch hours.
   - Movies generate more viewing records.
   - Average rating is approximately 3 out of 5.

   The following SQL queries validate these observations.
   ============================================================ */


-- Observation 1:
-- Overall churn rate

SELECT
    COUNT(*) AS total_users,
    SUM(Churn_Flag) AS churned_users,

    ROUND(
        AVG(Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage

FROM subscription_retention;


-- Observation 2:
-- Free Trial users have high churn

SELECT
    Subscription_Type,
    COUNT(*) AS total_users,
    SUM(Churn_Flag) AS churned_users,

    ROUND(
        AVG(Churn_Flag) * 100,
        2
    ) AS churn_rate_percentage

FROM subscription_retention

GROUP BY Subscription_Type

ORDER BY churn_rate_percentage DESC;


-- Observation 3:
-- Movies generate more viewing records
-- while TV Shows generate more watch hours

SELECT
    c.Content_Type,

    COUNT(v.Viewing_Record_ID)
        AS total_views,

    ROUND(
        SUM(v.Watch_Duration_Minutes) / 60,
        2
    ) AS total_watch_hours

FROM content_info c

JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID

GROUP BY c.Content_Type

ORDER BY total_watch_hours DESC;


/* ============================================================
   SECTION 33: JOINS AND SUB-QUERIES
   ============================================================ */

-- JOIN example:
-- Combine users with their subscription information

SELECT
    u.User_ID,
    u.Age_Group,
    u.Region,
    sr.Subscription_Type,
    sr.Churn_Flag

FROM user_profile u

JOIN subscription_retention sr
    ON u.User_ID = sr.User_ID

LIMIT 20;


-- JOIN example:
-- Combine content with viewing behaviour

SELECT
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform,
    v.Watch_Duration_Minutes,
    v.Completion_Percentage

FROM content_info c

JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID

LIMIT 20;


-- Sub-query example:
-- Find content whose average rating is above
-- the overall average rating

SELECT
    c.Content_ID,
    c.Title,

    AVG(r.Rating)
        AS average_rating

FROM content_info c

JOIN ratings_feedback r
    ON c.Content_ID = r.Content_ID

GROUP BY
    c.Content_ID,
    c.Title

HAVING AVG(r.Rating)
>
(
    SELECT AVG(Rating)
    FROM ratings_feedback
)

ORDER BY average_rating DESC;


/* ============================================================
   SECTION 34: AGGREGATIONS AND GROUPINGS
   ============================================================ */

-- Aggregation by platform

SELECT
    c.Platform,

    COUNT(v.Viewing_Record_ID)
        AS total_views,

    ROUND(
        SUM(v.Watch_Duration_Minutes) / 60,
        2
    ) AS watch_hours,

    ROUND(
        AVG(v.Completion_Percentage),
        2
    ) AS average_completion

FROM content_info c

JOIN viewing_activity v
    ON c.Content_ID = v.Content_ID

GROUP BY c.Platform

ORDER BY total_views DESC;


-- Aggregation by subscription type

SELECT
    Subscription_Type,

    COUNT(*) AS total_users,

    SUM(Churn_Flag)
        AS churned_users,

    ROUND(
        AVG(Churn_Flag) * 100,
        2
    ) AS churn_rate

FROM subscription_retention

GROUP BY Subscription_Type

ORDER BY churn_rate DESC;


/* ============================================================
   SECTION 35: DERIVED TABLES
   ============================================================ */

-- Derived table:
-- Calculate total views per content first,
-- then identify highly viewed content.

SELECT
    content_summary.Content_ID,
    content_summary.Title,
    content_summary.total_views

FROM
(
    SELECT
        c.Content_ID,
        c.Title,

        COUNT(v.Viewing_Record_ID)
            AS total_views

    FROM content_info c

    JOIN viewing_activity v
        ON c.Content_ID = v.Content_ID

    GROUP BY
        c.Content_ID,
        c.Title

) AS content_summary

WHERE content_summary.total_views
>
(
    SELECT AVG(total_views)

    FROM
    (
        SELECT
            Content_ID,
            COUNT(*) AS total_views

        FROM viewing_activity

        GROUP BY Content_ID

    ) AS average_content_views
)

ORDER BY content_summary.total_views DESC;


/* ============================================================
   SECTION 36: STORED PROCEDURE
   ============================================================ */

-- Stored procedure to return churn statistics
-- for a selected subscription type.

DROP PROCEDURE IF EXISTS GetSubscriptionChurn;

DELIMITER $$

CREATE PROCEDURE GetSubscriptionChurn
(
    IN p_subscription_type VARCHAR(50)
)

BEGIN

    SELECT
        Subscription_Type,

        COUNT(*) AS total_users,

        SUM(Churn_Flag)
            AS churned_users,

        SUM(Churn_Flag = 0)
            AS retained_users,

        ROUND(
            AVG(Churn_Flag) * 100,
            2
        ) AS churn_rate_percentage

    FROM subscription_retention

    WHERE Subscription_Type = p_subscription_type

    GROUP BY Subscription_Type;

END $$

DELIMITER ;


-- Example execution

CALL GetSubscriptionChurn('Premium');

CALL GetSubscriptionChurn('Basic');

CALL GetSubscriptionChurn('Free Trial');


/* ============================================================
   SECTION 37: STORED PROCEDURE WITH EXCEPTION HANDLING
   ============================================================ */

-- Stored procedure with:
-- 1. Input validation
-- 2. SQL exception handling
-- 3. Platform performance analysis

DROP PROCEDURE IF EXISTS GetPlatformPerformance;

DELIMITER $$

CREATE PROCEDURE GetPlatformPerformance
(
    IN p_platform VARCHAR(50)
)

BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION

    BEGIN

        SELECT
            'An SQL error occurred while processing the request.'
            AS error_message;

    END;


    -- Validate the supplied platform

    IF NOT EXISTS
    (
        SELECT 1
        FROM content_info
        WHERE Platform = p_platform
    )

    THEN

        SIGNAL SQLSTATE '45000'

        SET MESSAGE_TEXT =
        'Invalid platform supplied';

    END IF;


    -- Platform performance analysis

    SELECT
        c.Platform,

        COUNT(v.Viewing_Record_ID)
            AS total_views,

        ROUND(
            SUM(v.Watch_Duration_Minutes) / 60,
            2
        ) AS watch_hours,

        ROUND(
            AVG(v.Completion_Percentage),
            2
        ) AS average_completion

    FROM content_info c

    JOIN viewing_activity v
        ON c.Content_ID = v.Content_ID

    WHERE c.Platform = p_platform

    GROUP BY c.Platform;

END $$

DELIMITER ;


-- Example execution

CALL GetPlatformPerformance('NetStream');

CALL GetPlatformPerformance('AmazePrime');

CALL GetPlatformPerformance('DizPlay+');


/* ============================================================
   SECTION 37A: TRIGGERS
   ============================================================

   Purpose:

   Triggers automatically execute when specified INSERT
   or UPDATE operations occur.

   In this OTT project, triggers are used to maintain
   analytical data quality.

   Two types of validation are demonstrated:

   1. Rating validation
   2. Completion percentage validation
   ============================================================ */


/* ------------------------------------------------------------
   TRIGGER 1A: VALIDATE RATINGS DURING INSERT
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_validate_rating;

DELIMITER $$

CREATE TRIGGER trg_validate_rating

BEFORE INSERT ON ratings_feedback

FOR EACH ROW

BEGIN

    IF NEW.Rating < 1
       OR NEW.Rating > 5

    THEN

        SIGNAL SQLSTATE '45000'

        SET MESSAGE_TEXT =
        'Invalid rating: Rating must be between 1 and 5';

    END IF;

END $$

DELIMITER ;


/* ------------------------------------------------------------
   TRIGGER 1B: VALIDATE RATINGS DURING UPDATE
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_validate_rating_update;

DELIMITER $$

CREATE TRIGGER trg_validate_rating_update

BEFORE UPDATE ON ratings_feedback

FOR EACH ROW

BEGIN

    IF NEW.Rating < 1
       OR NEW.Rating > 5

    THEN

        SIGNAL SQLSTATE '45000'

        SET MESSAGE_TEXT =
        'Invalid rating: Rating must be between 1 and 5';

    END IF;

END $$

DELIMITER ;


/* ------------------------------------------------------------
   TRIGGER 2A: VALIDATE COMPLETION DURING INSERT
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_validate_completion;

DELIMITER $$

CREATE TRIGGER trg_validate_completion

BEFORE INSERT ON viewing_activity

FOR EACH ROW

BEGIN

    IF NEW.Completion_Percentage < 0
       OR NEW.Completion_Percentage > 100

    THEN

        SIGNAL SQLSTATE '45000'

        SET MESSAGE_TEXT =
        'Invalid completion percentage: Value must be between 0 and 100';

    END IF;

END $$

DELIMITER ;


/* ------------------------------------------------------------
   TRIGGER 2B: VALIDATE COMPLETION DURING UPDATE
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_validate_completion_update;

DELIMITER $$

CREATE TRIGGER trg_validate_completion_update

BEFORE UPDATE ON viewing_activity

FOR EACH ROW

BEGIN

    IF NEW.Completion_Percentage < 0
       OR NEW.Completion_Percentage > 100

    THEN

        SIGNAL SQLSTATE '45000'

        SET MESSAGE_TEXT =
        'Invalid completion percentage: Value must be between 0 and 100';

    END IF;

END $$

DELIMITER ;


/* ------------------------------------------------------------
   TEST TRIGGERS
   ------------------------------------------------------------

   DO NOT execute the following examples unless you
   intentionally want to generate validation errors.

   TEST 1:

   INSERT INTO ratings_feedback
   (
       User_ID,
       Content_ID,
       Rating,
       Liked_Flag,
       Feedback_Category
   )
   VALUES
   (
       1,
       'C0001',
       6,
       'Y',
       'Positive'
   );

   Expected result:
   Error because Rating = 6 is outside the valid range.


   TEST 2:

   INSERT INTO viewing_activity
   (
       Viewing_Record_ID,
       Session_ID,
       User_ID,
       Content_ID,
       View_Date,
       Watch_Duration_Minutes,
       Completion_Percentage,
       Paused_Times,
       Rewatched_Flag,
       Time_of_Day,
       Device_Type
   )
   VALUES
   (
       999999,
       999999,
       1,
       'C0001',
       '2025-01-01',
       60,
       150,
       0,
       'N',
       'Evening',
       'Mobile'
   );

   Expected result:
   Error because Completion_Percentage = 150.


   ------------------------------------------------------------ */


/* ------------------------------------------------------------
TRIGGERS
   ------------------------------------------------------------ */

SHOW TRIGGERS;


/* ============================================================
   TRIGGER INTERPRETATION
   ============================================================

   The triggers demonstrate automated data-quality control.

   1. trg_validate_rating prevents ratings outside the
      valid 1–5 scale during INSERT operations.

   2. trg_validate_rating_update prevents ratings outside
      the valid 1–5 scale during UPDATE operations.

   3. trg_validate_completion prevents completion percentages
      outside the valid 0–100% range during INSERT operations.

   4. trg_validate_completion_update prevents completion
      percentages outside the valid 0–100% range during
      UPDATE operations.

   These controls reduce the possibility of invalid values
   entering the analytical tables and protect the reliability
   of downstream SQL analysis, dashboards and reports.

   ============================================================ */


/* ============================================================
   SECTION 38: REUSABLE VIEW FOR ANALYTICAL OUTPUT
   ============================================================

   This view provides a reusable content-performance dataset.

   IMPORTANT:
   Viewing and rating data are aggregated separately before
   joining to content. This prevents row multiplication.

   The metrics in this view are CONTENT-LEVEL metrics.

   ============================================================ */

DROP VIEW IF EXISTS vw_content_analysis;

CREATE VIEW vw_content_analysis AS

WITH viewing_summary AS
(
    SELECT
        Content_ID,

        COUNT(*) AS total_views,

        ROUND(
            SUM(Watch_Duration_Minutes) / 60,
            2
        ) AS watch_hours,

        ROUND(
            AVG(Completion_Percentage),
            2
        ) AS average_completion

    FROM viewing_activity

    GROUP BY Content_ID
),

rating_summary AS
(
    SELECT
        Content_ID,

        COUNT(*) AS rating_count,

        ROUND(
            AVG(Rating),
            2
        ) AS average_rating

    FROM ratings_feedback

    GROUP BY Content_ID
)

SELECT
    c.Content_ID,
    c.Title,
    c.Content_Type,
    c.Platform,

    COALESCE(
        vs.total_views,
        0
    ) AS total_views,

    COALESCE(
        vs.watch_hours,
        0
    ) AS watch_hours,

    COALESCE(
        vs.average_completion,
        0
    ) AS average_completion,

    COALESCE(
        rs.rating_count,
        0
    ) AS rating_count,

    COALESCE(
        rs.average_rating,
        0
    ) AS average_rating

FROM content_info c

LEFT JOIN viewing_summary vs
    ON c.Content_ID = vs.Content_ID

LEFT JOIN rating_summary rs
    ON c.Content_ID = rs.Content_ID;


/* View analytical output */

SELECT *
FROM vw_content_analysis
ORDER BY total_views DESC
LIMIT 20;


/*
NOTE:

average_completion and average_rating in this view represent
content-level metrics.

For overall or platform-level weighted averages, calculations
should use the original viewing_activity and ratings_feedback
records or appropriately aggregated totals.
*/


/* ============================================================
   SECTION 39: TREND INTERPRETATION
   ============================================================ */

-- Monthly viewing trend

SELECT
    DATE_FORMAT(View_Date,'%Y-%m')
        AS viewing_month,

    COUNT(*) AS total_views,

    ROUND(
        SUM(Watch_Duration_Minutes) / 60,
        2
    ) AS watch_hours

FROM viewing_activity

GROUP BY DATE_FORMAT(View_Date,'%Y-%m')

ORDER BY viewing_month;


/*
INTERPRETATION:

The monthly aggregation allows management to identify
increases or decreases in viewing activity over time.

Higher total views indicate increased platform traffic,
while higher watch hours indicate deeper viewing activity.

This analysis can be compared with content releases,
promotional campaigns and seasonal viewing patterns.
*/


/* ============================================================
   SECTION 40: CORRELATION-SUPPORTING SQL ANALYSIS
   ============================================================

   SQL provides grouped evidence related to the relationship
   between watch duration and completion.

   The actual statistical correlation/regression analysis
   was performed separately in Python.

   ============================================================ */

-- Compare watch duration and completion across
-- viewing-duration categories.

SELECT

    CASE
        WHEN Watch_Duration_Minutes <= 60
            THEN 'Short'

        WHEN Watch_Duration_Minutes <= 225
            THEN 'Medium'

        ELSE 'Long'
    END AS watch_duration_category,

    COUNT(*) AS viewing_records,

    ROUND(
        AVG(Watch_Duration_Minutes),
        2
    ) AS average_watch_duration,

    ROUND(
        AVG(Completion_Percentage),
        2
    ) AS average_completion

FROM viewing_activity

GROUP BY

    CASE
        WHEN Watch_Duration_Minutes <= 60
            THEN 'Short'

        WHEN Watch_Duration_Minutes <= 225
            THEN 'Medium'

        ELSE 'Long'
    END

ORDER BY average_watch_duration;


/*
INTERPRETATION:

This SQL analysis does not establish causation and does not
replace statistical correlation or regression analysis.

It provides grouped SQL evidence showing how completion
behaviour differs across watch-duration categories.

The Python regression analysis found a weak positive relationship
between watch duration and completion percentage, with R²
approximately 4.86%.

Therefore, watch duration alone explains only a small portion
of the variation in completion behaviour.
*/


/* ============================================================
   SECTION 41: CONNECTING SQL RESULTS TO THE
   PROBLEM STATEMENT AND HYPOTHESIS
   ============================================================ */


/*
PROBLEM STATEMENT:

The OTT platform needs to understand viewing behaviour,
content performance and customer retention patterns in order
to support data-driven content and business decisions.


HYPOTHESIS 1:
Subscription behaviour is associated with customer churn.

SQL evidence:
SECTION 10, SECTION 26 and SECTION 36.

Finding:
Churn rates differ substantially across subscription types,
with Free Trial users showing the highest churn and Premium
users showing stronger retention.


HYPOTHESIS 2:
Content type influences viewing engagement.

SQL evidence:
SECTION 10 and SECTION 13.

Finding:
Movies generate more viewing records, while TV Shows generate
substantially more watch hours.


HYPOTHESIS 3:
Content quality and satisfaction can be evaluated through
ratings and feedback.

SQL evidence:
SECTION 15, SECTION 25 and SECTION 38.

Finding:
Average ratings and feedback distribution provide evidence
about audience satisfaction and content quality.


HYPOTHESIS 4:
Viewer behaviour differs across platforms and devices.

SQL evidence:
SECTION 10, SECTION 24 and SECTION 38.

Finding:
Average completion and viewing volume vary across platforms
and devices, indicating opportunities for platform-specific
engagement strategies.


OVERALL CONCLUSION:

SQL converts the observations identified during Python EDA
into reproducible, query-driven business evidence.

Joins connect the five datasets, aggregations identify
important patterns, sub-queries compare groups against
benchmarks, derived tables support intermediate analysis,
views provide reusable outputs, stored procedures provide
reusable analytical logic, and triggers provide automated
data-quality controls.

These results directly support the OTT business problem by
identifying retention risks, content opportunities and
engagement patterns.
*/


/* ============================================================
   SECTION 42: FINAL 10 IMPORTANT BUSINESS QUESTIONS
   ============================================================

   These are the final business questions selected for the
   project presentation and documentation.

   The actual executable SQL queries are already included
   in the sections above. They are not repeated here.

   ============================================================ */

-- 1. What is the overall churn rate?
--    SQL Evidence: Sections 10, 26 and 29


-- 2. Which subscription type has the highest churn?
--    SQL Evidence: Sections 10, 26 and 36


-- 3. Which subscription type has the highest renewal rate?
--    SQL Evidence: Section 10


-- 4. Which age group and subscription combination has
--    the highest churn?
--    SQL Evidence: Section 11


-- 5. Which platform receives the highest number of views?
--    SQL Evidence: Sections 10, 30 and 38


-- 6. Do Movies or TV Shows generate more watch hours?
--    SQL Evidence: Sections 10 and 32


-- 7. Which content generates the highest number of views?
--    SQL Evidence: Sections 13 and 38


-- 8. Which content has the highest completion rate?
--    SQL Evidence: Sections 13 and 38


-- 9. What do ratings and feedback reveal about
--    customer satisfaction?
--    SQL Evidence: Sections 15, 25 and 38


-- 10. What are the key overall OTT performance KPIs?
--     SQL Evidence: Section 29


/* ============================================================
   FINAL BUSINESS INSIGHTS FROM SQL ANALYSIS
   ============================================================

   1. Overall churn is high at approximately 44.4%, indicating
      a significant customer retention challenge.

   2. Free Trial users have the highest churn rate, while
      Premium users show substantially stronger retention.

   3. Premium customers demonstrate the strongest renewal
      behaviour and represent an important customer segment
      to protect.

   4. Movies generate much higher viewing traffic, while
      TV Shows generate substantially more total watch hours.
      This indicates that Movies support discovery while
      TV Shows support deeper engagement.

   5. DizPlay+ has lower viewing volume but achieves the
      highest average completion rate among the platforms,
      indicating strong engagement efficiency.

   6. Overall average content rating is approximately 3 out
      of 5, showing moderate customer satisfaction.

   7. Positive and negative feedback volumes are relatively
      close, indicating that content relevance and quality
      should be monitored carefully.

   8. A substantial number of viewing records exceed the
      225-minute business-defined threshold, indicating
      highly long viewing sessions and a highly skewed
      watch-duration distribution.

   9. Viewer completion differs across devices and time
      periods, providing opportunities for device-specific
      and time-specific engagement strategies.

   10. Specific combinations of age group, subscription,
       engagement level and region show higher churn than
       the overall population, supporting targeted rather
       than one-size-fits-all retention strategies.


   ============================================================
   FINAL BUSINESS RECOMMENDATIONS
   ============================================================

   1. Improve Free Trial Conversion
      - Introduce personalised content recommendations.
      - Send reminders and personalised watch suggestions
        before the trial expires.
      - Provide targeted offers to high-engagement trial users.

   2. Protect Premium Customers
      - Provide personalised recommendations.
      - Introduce loyalty benefits and early access to selected
        content.
      - Monitor changes in engagement before renewal periods.

   3. Use TV Shows to Drive Retention
      - Invest in high-performing episodic content.
      - Promote the next episode after completion.
      - Use series recommendations to encourage continued viewing.

   4. Use Movies to Drive Discovery
      - Promote popular movies on home pages.
      - Use movie popularity to attract and activate users.
      - Cross-recommend movies with relevant TV series.

   5. Improve Content Recommendations
      - Combine viewing history, completion percentage,
        ratings and feedback.
      - Recommend content based on actual user behaviour
        rather than popularity alone.

   6. Address Negative Feedback
      - Identify content with high negative feedback.
      - Analyse low-rated and low-completion content.
      - Use feedback patterns to support content acquisition
        and removal decisions.

   7. Target High-Risk Customer Segments
      - Use age group, subscription type, engagement level
        and region together to identify high-churn segments.
      - Create targeted retention campaigns for these groups.

   8. Monitor Long Viewing Sessions
      - Investigate extreme watch-duration records.
      - Distinguish legitimate binge-watching from possible
        data-quality or session-tracking issues.

   9. Optimise Platform Experience
      - Monitor completion and engagement by platform and device.
      - Improve user experience on devices showing comparatively
        lower completion.

   10. Build a Management Dashboard
       - Track churn rate.
       - Renewal rate.
       - Total watch hours.
       - Average completion.
       - Average rating.
       - Platform performance.
       - Content performance.
       - Feedback distribution.


   ============================================================
   PROJECT CONCLUSION
   ============================================================

   The SQL analysis shows that the OTT platform has a major
   opportunity to improve customer retention while optimising
   content strategy.

   The 44.4% churn rate indicates that retention should be a
   major business priority, particularly among Free Trial users.

   Premium users demonstrate stronger retention and therefore
   represent an important segment to protect.

   Content behaviour also reveals two different strategic
   roles. Movies generate high viewing traffic and can support
   content discovery, while TV Shows generate substantially
   higher watch hours and can support deeper engagement and
   retention.

   Platform, device, demographic, subscription, viewing and
   feedback analysis together provide a stronger basis for
   decision-making than any single metric.

   Therefore, the platform should combine customer segmentation,
   personalised recommendations, targeted retention campaigns
   and data-driven content investment to improve engagement,
   satisfaction and long-term customer value.

   ============================================================
   END OF OTT SQL ANALYSIS PROJECT
   ============================================================ */