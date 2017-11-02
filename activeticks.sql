/*
Definition: sum( active ticks in hours for the day ) / number of profiles active on day
Owner: Saptarshi Guha (sguha@mozilla.com)
Reviewed by: Ryan Harter (rharter@mozilla.com)
Reviewed on: 2017-11-01
TODO:
 - Fix app version filter
 - Remove sampling
 - Fix column names (s/56/57/g)
Done:
 - change column names
*/

WITH filtered_data AS (
    SELECT 
        client_id,
        submission_date_s3,
        SUBSTRING(app_version, 1, 2) = '56' AS is_new_version,
        subsession_length AS subsession_hours,
        active_ticks AS active_hours
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
        SUM(subsession_hours) / 3600 as subsession_hours_all,
        SUM(active_hours) * 5 / 3600 as active_hours_all,
        SUM(IF(is_new_version, subsession_hours, NULL)) / 3600  as subsession_hours_new,
        SUM(IF(is_new_version, active_hours, NULL)) * 5 / 3600 as active_hours_new
    FROM filtered_data
    GROUP BY 1, 2
),
daily_data AS (
    SELECT
        submission_date_s3 AS date,
        AVG(subsession_hours_new) AS avg_subsess_hours_new,
        AVG(active_hours_new) AS avg_active_hours_new,
        AVG(subsession_hours_all) AS avg_subsess_hours_all,
        AVG(active_hours_all) AS avg_active_hours_all
    FROM client_data
    GROUP BY 1
    ORDER BY 1
)

SELECT
    date,
    avg_subsess_hours_new,
    avg_active_hours_new,
    avg_subsess_hours_all,
    avg_active_hours_all
FROM daily_data
ORDER BY 1

