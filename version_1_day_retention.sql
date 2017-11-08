-- https://sql.telemetry.mozilla.org/queries/47967/source#table
 WITH population AS
  (SELECT split(app_version, '.')[1] AS major_version,
                                 cast(hll AS HLL) AS client_count,
                                 days_since_creation as elapsed_periods
   FROM retention
   WHERE days_since_creation >= 0
     AND days_since_creation <= 14
     AND channel = 'release'
     AND split(app_version, '.')[1] IN ('55',
                                        '56') ),
      population_agg AS
  (SELECT major_version,
          cardinality(merge(client_count)) AS total
   FROM population
   WHERE elapsed_periods = 0
   GROUP BY 1) -- The total count of profiles that were created during this version

SELECT *, (0.0 + value)*100/total AS percentage
FROM
  (SELECT p.major_version,
          elapsed_periods AS day_number,
          cardinality(merge(client_count)) AS value,
          total
   FROM population p
   JOIN population_agg pa ON p.major_version = pa.major_version
   GROUP BY 1,
            2,
            4)
