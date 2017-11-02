/*
Definition: sum( active ticks in hours for the day ) / number of profiles active on day
Owner: Saptarshi Guha (sguha@mozilla.com)
Reviewed by: Ryan Harter (rharter@mozilla.com)
Reviewed on: 2017-11-01
TODO:
 - Fix app version filter
 - Remove sampling
 - Fix column names (s/56/57/g)
*/

WITH a AS (
    SELECT 
        client_id,
        submission_date_s3,
        SUM(subsession_length) / 3600 AS thours,
        SUM(active_ticks) * 5 / 3600 AS ahours
    FROM main_summary
    WHERE app_name = 'Firefox'
        AND normalized_channel =' release'
        AND SUBSTRING(app_version, 1, 2) = '56'
        AND submission_date_s3 >= '20170925'
        AND subsession_length <= 86400
        AND subsession_length >= 0
        AND active_ticks>=0
        AND sample_id='42'
    GROUP BY 1, 2
),
b AS (
    SELECT
        submission_date_s3 AS date,
        AVG(thours) AS thrs56,
        AVG(ahours) AS ahrs56
    FROM a
    GROUP BY 1
    ORDER BY 1
),
c AS (
SELECT
    client_id,
    submission_date_s3,
    SUM(subsession_length) / 3600 AS thours,
    SUM(active_ticks) * 5 / 3600 as ahours
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
        AVG(thours) as thrsAll,
        AVG(ahours) as ahrsAll
    FROM c GROUP BY 1
    ORDER BY 1
)

SELECT
    d.date,
    thrsAll,
    thrs56,
    ahrsAll,
    ahrs56
FROM b
JOIN d ON b.date = d.date
ORDER BY 1
