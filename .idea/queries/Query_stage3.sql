/*
START STAGE 3 Query
*/
WITH trip_stats AS (
  SELECT
    t.trip_no,
    CONCAT(t.town_from, '-', t.town_to) AS route,
    TIMESTAMPDIFF(MINUTE, t.time_out, t.time_in) AS duration_minutes,
    TIMESTAMPDIFF(SECOND, t.time_out, t.time_in) AS duration_seconds,
    COUNT(pit.ID_psg) AS passengers_on_trip
  FROM Trip t
  LEFT JOIN Pass_in_trip pit ON t.trip_no = pit.trip_no
  GROUP BY t.trip_no, route, duration_minutes, duration_seconds
)
SELECT
  route,
  ROUND(AVG(duration_minutes)) AS avg_flight_duration,
  SUM(passengers_on_trip) AS total_passengers,
  ROUND(SUM(duration_seconds * passengers_on_trip) * 0.01) AS total_income
FROM trip_stats
GROUP BY route
ORDER BY total_income DESC;
/*
END STAGE 3 Query
*/

/*
Other Solution:
--
SELECT
    CONCAT(t.town_from, '-', t.town_to) AS route,
    AVG(TIMESTAMPDIFF(MINUTE, t.time_out, t.time_in)) AS avg_flight_duration,
    COUNT(pit.ID_psg) AS total_passengers,
    ROUND(SUM(TIMESTAMPDIFF(SECOND, t.time_out, t.time_in)) / 100) AS total_income
FROM
    Trip t
LEFT JOIN
    Pass_in_trip pit ON t.trip_no = pit.trip_no
GROUP BY
    route
ORDER BY
    total_income DESC;
 */
