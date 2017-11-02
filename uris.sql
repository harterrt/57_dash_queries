WITH a AS (
    SELECT
        client_id,
        submission_date_s3,
        SUM(scalar_parent_browser_engagement_total_uri_count) AS uri
    FROM main_summary
    WHERE app_name = 'Firefox'
      AND normalized_channel = 'release'
      AND SUBSTRING(app_version, 1, 2) = '56'
      AND submission_date_s3 >= '20170925'
      AND subsession_length <= 86400 
      AND subsession_length >= 0 
      AND active_ticks >= 0
      AND sample_id = '42'
GROUP BY 1, 2
),
b AS (
    SELECT 
        submission_date_s3 AS date,
        AVG(uri) as uri56
    FROM a 
    GROUP BY 1 
    ORDER BY 1
),
c AS (
    SELECT 
        client_id, 
        submission_date_s3, 
        SUM(scalar_parent_browser_engagement_total_uri_count) AS uri
    FROM main_summary
    WHERE app_name = 'Firefox'
      AND submission_date_s3 >= '20170925'
      AND normalized_channel = 'release'
      AND subsession_length <= 86400 
      AND subsession_length >= 0 
      AND active_ticks >= 0
      AND sample_id = '42'
    GROUP BY 1, 2
),
d AS (
    SELECT 
        submission_date_s3 AS date,
        AVG(uri) AS uriAll
    FROM c
    GROUP BY 1 
    ORDER BY 1
)

SELECT
    d.date,
    uriAll,
    uri56 
FROM b
JOIN d ON b.date=d.date
ORDER BY 1
