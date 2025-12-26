/*
START STAGE 5 Query
This returns, for each airline (company_name), the top two routes (departure_city → arrival_city) ranked by
average flight duration in minutes.
*/
WITH RouteDuration AS (
    SELECT
        ac.company_name,
        t.town_from AS departure_city,
        t.town_to AS arrival_city,
        AVG(TIMESTAMPDIFF(MINUTE, t.time_out, t.time_in)) AS avg_flight_duration
    FROM Trip t
    JOIN Airline_company ac ON t.ID_comp = ac.ID_comp
    WHERE t.time_out IS NOT NULL
      AND t.time_in IS NOT NULL
      AND t.town_from <> t.town_to
    GROUP BY ac.company_name, t.town_from, t.town_to
),
RankedRoutes AS (
    SELECT
        company_name,
        departure_city,
        arrival_city,
        avg_flight_duration,
        ROW_NUMBER() OVER (PARTITION BY company_name ORDER BY avg_flight_duration DESC) AS 'rank'
    FROM RouteDuration
)
SELECT
    company_name,
    departure_city,
    arrival_city,
    avg_flight_duration
FROM RankedRoutes
WHERE 'rank' <= 2
ORDER BY company_name, avg_flight_duration DESC;
/*
END STAGE 5 Query
*/


/*
Other Solution:
--
*/