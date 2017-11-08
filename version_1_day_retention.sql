WITH population AS (
    SELECT
        split(app_version, '.')[1] AS major_version,
        cast(hll AS HLL) AS client_count,
        days_since_creation as day_number
    FROM retention
    WHERE days_since_creation >= 0
      AND days_since_creation <= 14
      AND channel = 'release'
      AND split(app_version, '.')[1] IN ('55', '56')
), -- two week user_counts for release on 55 & 56
version_totals AS (
    SELECT 
        major_version,
        cardinality(merge(client_count)) AS version_total
    FROM population
    WHERE day_number = 0 -- Why limit to day 0? Should be a no-op, right?
    GROUP BY 1
), -- The total count of profiles that were created for each version
daily_totals AS (
    SELECT
        major_version,
        day_number,
        cardinality(merge(client_count)) AS daily_total
    FROM population
    GROUP BY 1, 2
),
combined AS (
    SELECT
        daily_totals.major_version AS major_version,
        daily_totals.day_number AS day_number,
        daily_total,
        version_total
    FROM daily_totals
    JOIN version_totals
      ON daily_totals.major_version = version_totals.major_version
)

SELECT 
    *,
    (0.0 + daily_total) * 100 / version_total AS percentage
FROM combined
