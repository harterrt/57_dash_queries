/*
Definition: sum(uri visited on a day) / sum(total hours used on day) averaged across profiles
Owner: Saptarshi Guha (sguha@mozilla.com)
Reviewed by: Ryan Harter (rharter@mozilla.com)
Reviewed on: 2017-11-01
TODO:
 - Fix app version filter
 - Remove sampling
*/

WITH filtered_data AS (
    SELECT 
        client_id,
        submission_date_s3,
        SUBSTRING(app_version, 1, 2) = '56' AS is_new_version,
        scalar_parent_browser_engagement_total_uri_count AS uri
    FROM main_summary
    WHERE app_name = 'Firefox'
        AND normalized_channel = 'release'
        AND submission_date_s3 >= '20170925'
        AND subsession_length <= 86400
        AND subsession_length >= 0
        AND active_ticks>=0
        AND sample_id='42'
),
client_data AS (
    SELECT
        client_id,
        submission_date_s3,
        SUM(uri) as uri_all,
        SUM(IF(is_new_version, uri, NULL)) as uri_new
    FROM filtered_data
    GROUP BY 1, 2
),
daily_data AS (
    SELECT
        submission_date_s3 AS date,
        AVG(uri_new) AS avg_uri_new,
        AVG(uri_all) AS avg_uri_all
    FROM client_data
    GROUP BY 1
    ORDER BY 1
)

SELECT
    date,
    avg_uri_new,
    avg_uri_all
FROM daily_data
ORDER BY 1
