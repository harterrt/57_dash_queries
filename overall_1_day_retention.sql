WITH population AS (
    SELECT
        subsession_start,
        merge(cast(hll AS HLL)) AS hll,
        days_since_creation
    FROM retention
    WHERE days_since_creation >= 0
      AND days_since_creation <= 14
      AND days_since_creation < date_diff('day', date '2017-06-26', CURRENT_DATE)
      AND channel = 'release'
   GROUP BY 1, 3
), -- The count of profiles broken down by subsession_start and and days relative to the start
population_agg AS (
    SELECT 
        subsession_start,
        cardinality(merge(hll)) AS total
    FROM population
    WHERE days_since_creation = 0
    GROUP BY 1
) -- The total count of first session profiles for each date

SELECT 
    population.subsession_start AS date,
    days_since_creation AS day_number,
    cardinality(merge(hll)) AS value,
    total
FROM population
JOIN population_agg
  ON population.subsession_start = population_agg.subsession_start
WHERE days_since_creation > 0
GROUP BY 1, 2, 4
