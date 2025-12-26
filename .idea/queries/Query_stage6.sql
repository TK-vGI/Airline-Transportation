/*
START STAGE 6 Query
*/
WITH PassengerIncome AS (
    SELECT
        p.ID_psg,
        p.passenger_name,
        COALESCE(SUM(TIMESTAMPDIFF(SECOND, t.time_out, t.time_in)), 0) * 0.01 AS passenger_income_dollars_raw
    FROM Passenger p
    LEFT JOIN Pass_in_trip pit ON p.ID_psg = pit.ID_psg
    LEFT JOIN Trip t ON pit.trip_no = t.trip_no
        AND t.time_out IS NOT NULL
        AND t.time_in IS NOT NULL
        AND t.town_from <> t.town_to
    GROUP BY p.ID_psg, p.passenger_name
),
WithTotals AS (
    SELECT
        ID_psg,
        passenger_name,
        passenger_income_dollars_raw AS passenger_income_dollars,
        SUM(passenger_income_dollars_raw) OVER () AS total_income
    FROM PassengerIncome
),
Ranked AS (
    SELECT
        ID_psg,
        passenger_name,
        passenger_income_dollars,
        SUM(passenger_income_dollars) OVER (
            ORDER BY passenger_income_dollars DESC, ID_psg
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_income,
        total_income
    FROM WithTotals
)
SELECT
    ID_psg,
    passenger_name,
    ROUND(passenger_income_dollars, 2) AS passenger_income_dollars,
    ROUND(
        CASE
            WHEN total_income = 0 THEN 0
            ELSE (running_income / total_income) * 100
        END
    , 2) AS cumulative_share_percent,
    CASE
        WHEN total_income = 0 THEN 'C'
        WHEN (running_income / total_income) * 100 <= 80 THEN 'A'
        WHEN (running_income / total_income) * 100 <= 95 THEN 'B'
        ELSE 'C'
    END AS category
FROM Ranked
ORDER BY (running_income / NULLIF(total_income, 0));

/*
END STAGE 6 Query
*/


/*
Other Solution:
--
WITH passenger_share AS (
	SELECT p.id_psg,
		   p.passenger_name,
		   SUM(TIMESTAMPDIFF(SECOND, t.time_out, t.time_in)/100) AS passenger_income_dollars,
		   SUM(TIMESTAMPDIFF(SECOND, t.time_out, t.time_in)/100) * 100 /
		   (
			SELECT
		   	   SUM(TIMESTAMPDIFF(SECOND, t.time_out, t.time_in)/100) AS total_income_dollars
             FROM Passenger p
			 INNER JOIN Pass_in_trip pt ON pt.id_psg = p.id_psg
			 INNER JOIN Trip t ON t.trip_no = pt.trip_no
			) as share_percent
	FROM Passenger p
	INNER JOIN Pass_in_trip pt ON pt.id_psg = p.id_psg
	INNER JOIN Trip t ON t.trip_no = pt.trip_no
	GROUP BY p.id_psg
	ORDER BY 3 DESC
),
cumulative_share AS (
	SELECT id_psg,
		   passenger_name,
		   ROUND(passenger_income_dollars) as passenger_income_dollars ,
	   	   ROUND(SUM(share_percent) OVER(ORDER BY ROUND(passenger_income_dollars) DESC), 2) AS cumulative_share_percent
	FROM passenger_share
	ORDER BY 3 DESC
)

SELECT *,
	   CASE
	   		WHEN cumulative_share_percent <= 80.00 THEN 'A'
			WHEN cumulative_share_percent >= 80.01 AND cumulative_share_percent <= 95.00 THEN 'B'
			WHEN cumulative_share_percent >= 95.01 THEN 'C'
	   END AS category
FROM cumulative_share
*/

/*
Other Solution:
--
WITH PassengerIncome AS (
    SELECT
        p.ID_psg,
        p.passenger_name,
        SUM(TIMESTAMPDIFF(SECOND, t.time_out, t.time_in) * 0.01) AS passenger_income_dollars
    FROM
        Passenger AS p
    JOIN
        Pass_in_trip AS pit ON p.ID_psg = pit.ID_psg
    JOIN
        Trip AS t ON pit.trip_no = t.trip_no
    GROUP BY
        p.ID_psg, p.passenger_name
)
SELECT
    ID_psg,
    passenger_name,
    passenger_income_dollars,
    ROUND(
        SUM(passenger_income_dollars) OVER (ORDER BY passenger_income_dollars DESC)
        / SUM(passenger_income_dollars) OVER () * 100, 2
    ) AS cumulative_share_percent,
    CASE
        WHEN SUM(passenger_income_dollars) OVER (ORDER BY passenger_income_dollars DESC)
             / SUM(passenger_income_dollars) OVER () * 100 <= 80 THEN 'A'
        WHEN SUM(passenger_income_dollars) OVER (ORDER BY passenger_income_dollars DESC)
             / SUM(passenger_income_dollars) OVER () * 100 <= 95 THEN 'B'
        ELSE 'C'
    END AS category
FROM
    PassengerIncome
ORDER BY
    cumulative_share_percent;
 */

/*
Other Solution:
--
WITH PassengerIncome AS (
    SELECT
        Pass_in_trip.ID_psg,
        SUM(TIMESTAMPDIFF(MINUTE, Trip.time_out, Trip.time_in) * 0.6) AS passenger_income_dollars
    FROM
        Trip
    LEFT JOIN
        Pass_in_trip
    ON Trip.trip_no = Pass_in_trip.trip_no
    GROUP BY
        Pass_in_trip.ID_psg
    ),
     CumulativeShare AS (
    SELECT
        ID_psg,
        passenger_income_dollars,
        ROUND(100 * SUM(passenger_income_dollars) OVER
        (ORDER BY passenger_income_dollars DESC, ID_psg ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        / SUM(passenger_income_dollars) OVER (), 2) AS cumulative_share_percent
    FROM
        PassengerIncome
     )
SELECT
    Passenger.ID_psg,
    Passenger.passenger_name,
    CumulativeShare.passenger_income_dollars,
    CumulativeShare.cumulative_share_percent,
    CASE
    WHEN CumulativeShare.cumulative_share_percent < 80.00 THEN 'A'
    WHEN CumulativeShare.cumulative_share_percent >= 80.00
        AND CumulativeShare.cumulative_share_percent <= 95.00 THEN 'B'
    WHEN CumulativeShare.cumulative_share_percent > 95.00 THEN 'C'
    END AS category
FROM
    CumulativeShare
LEFT JOIN
    Passenger
ON CumulativeShare.ID_psg = Passenger.ID_psg
*/