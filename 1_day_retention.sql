WITH filtered AS (
    SELECT 
        subsession_start,
        days_since_creation
        merge(cast(hll AS HLL)) AS hll,
    FROM retention
    WHERE days_since_creation >= 0
      AND days_since_creation <= 14
      AND days_since_creation < date_diff('day', date '2017-06-26', CURRENT_DATE)
      AND channel = 'release'
),
daily_retention AS (
    SELECT 
        subsession_start,
        days_since_creation
        merge(cast(hll AS HLL)) AS hll,
    FROM filtered
    GROUP BY 1, 2
), -- The count of profiles broken down by subsession_start and and days relative to the start
daily_new_profiles AS (
    SELECT 
        subsession_start,
        cardinality(merge(hll)) AS total
    FROM population
    GROUP BY 1
) -- The total count of first session profiles for each date

SELECT 
    population.subsession_start AS date,
    days_since_creation AS day_number,
    cardinality(merge(hll)) AS value,
    total
FROM daily_retention
JOIN daily_new_profiles 
  ON daily_retention.subsession_start = daily_new_profiles.subsession_start
WHERE days_since_creation >= 0
GROUP BY 1, 2, 4
