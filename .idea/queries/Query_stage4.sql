/*
START STAGE 3 Query
*/
SELECT
    'Boeing' AS aircraft_type,
    AVG(TIMESTAMPDIFF(MINUTE, time_out, time_in)) AS avg_flight_duration,
    COUNT(*) AS num_flights
FROM Trip
WHERE plane_type LIKE 'Boeing%'
  AND time_out IS NOT NULL
  AND time_in IS NOT NULL
  AND town_from <> town_to

UNION ALL

SELECT
    'Airbus' AS aircraft_type,
    AVG(TIMESTAMPDIFF(MINUTE, time_out, time_in)) AS avg_flight_duration,
    COUNT(*) AS num_flights
FROM Trip
WHERE plane_type LIKE 'Airbus%'
  AND time_out IS NOT NULL
  AND time_in IS NOT NULL
  AND town_from <> town_to;

/*
END STAGE 3 Query
*/

/*
Other Solution:
--
SELECT
    CASE WHEN plane_type LIKE 'Airbus%' THEN 'Airbus' ELSE 'Boeing' END AS aircraft_type,
    AVG(TIMESTAMPDIFF(MINUTE, time_out, time_in)) AS avg_flight_duration,
    COUNT(*) AS num_flights
FROM Trip
GROUP BY aircraft_type;
*/

/*
Other Solution:
--
SELECT
    CASE
        WHEN plane_type LIKE 'Boeing%' THEN 'Boeing'
        WHEN plane_type LIKE 'Airbus%' THEN 'Airbus'
    END AS aircraft_type,
    AVG(TIMESTAMPDIFF(MINUTE, time_out, time_in)) AS avg_flight_duration,
    COUNT(trip_no) AS num_flights
FROM
    Trip
WHERE
    plane_type LIKE 'Boeing%' OR plane_type LIKE 'Airbus%'
GROUP BY
    aircraft_type
ORDER BY
    aircraft_type;
*/

/*
SELECT
  aircraft_type,
  AVG(duration_min) AS avg_flight_duration,
  COUNT(*) AS num_flights
FROM (
  SELECT
    CASE
      WHEN t.plane_type LIKE 'Boeing%' THEN 'Boeing'
      WHEN t.plane_type LIKE 'Airbus%' THEN 'Airbus'
      ELSE NULL
    END AS aircraft_type,
    TIMESTAMPDIFF(MINUTE, t.time_out, t.time_in) AS duration_min
  FROM Trip t
  WHERE t.plane_type IS NOT NULL
    AND (t.plane_type LIKE 'Boeing%' OR t.plane_type LIKE 'Airbus%')
    AND t.time_out IS NOT NULL
    AND t.time_in IS NOT NULL
    AND t.town_from <> t.town_to
) AS sub
WHERE aircraft_type IS NOT NULL
GROUP BY aircraft_type
ORDER BY aircraft_type;
*/

-- continuation
/*
Breakdown by airline and aircraft type
durations and frequencies vary per airline, this query preserves the required first three columns and
then adds the airline identifier and name for context.

SELECT
  sub.aircraft_type,
  sub.avg_flight_duration,
  sub.num_flights,
  ac.ID_comp,
  ac.company_name
FROM (
  SELECT
    CASE
      WHEN t.plane_type LIKE 'Boeing%' THEN 'Boeing'
      WHEN t.plane_type LIKE 'Airbus%' THEN 'Airbus'
        END AS aircraft_type,
    AVG(TIMESTAMPDIFF(MINUTE, t.time_out, t.time_in)) AS avg_flight_duration,
    COUNT(*) AS num_flights,
    t.ID_comp
  FROM Trip t
  WHERE (t.plane_type LIKE 'Boeing%' OR t.plane_type LIKE 'Airbus%')
    AND t.time_out IS NOT NULL
    AND t.time_in IS NOT NULL
    AND t.town_from <> t.town_to
  GROUP BY aircraft_type, t.ID_comp
) AS sub
JOIN Airline_company ac ON ac.ID_comp = sub.ID_comp
ORDER BY sub.aircraft_type, sub.num_flights DESC;
 */

/*
Per‑flight dataset export for statistical testing
To run a statistical test (for example, a two‑sample t‑test) you may want the raw per‑flight durations labeled
by aircraft_type. This query produces one row per flight with aircraft_type and duration_min. Export the result
from your DB client and run the test in Python/R.

SELECT
  CASE
    WHEN t.plane_type LIKE 'Boeing%' THEN 'Boeing'
    WHEN t.plane_type LIKE 'Airbus%' THEN 'Airbus'
      END AS aircraft_type,
  TIMESTAMPDIFF(MINUTE, t.time_out, t.time_in) AS duration_min,
  t.trip_no,
  t.ID_comp
FROM Trip t
WHERE (t.plane_type LIKE 'Boeing%' OR t.plane_type LIKE 'Airbus%')
  AND t.time_out IS NOT NULL
  AND t.time_in IS NOT NULL
  AND t.town_from <> t.town_to;
 */