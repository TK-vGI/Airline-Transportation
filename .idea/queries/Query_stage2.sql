/*
START STAGE 2 Query
*/
SELECT
  p.passenger_name,
  COUNT(*) AS num_flights,
  ac.company_name
FROM Passenger p
JOIN Pass_in_trip pit ON p.ID_psg = pit.ID_psg
JOIN Trip t ON pit.trip_no = t.trip_no
JOIN Airline_company ac ON t.ID_comp = ac.ID_comp
GROUP BY p.passenger_name, ac.company_name
HAVING num_flights > 1
ORDER BY ac.company_name, num_flights DESC, p.passenger_name;
/*
END STAGE 2 Query
*/

/*
Other Solution:
--
WITH all_data AS (
	SELECT p.passenger_name, t.trip_no, a.company_name
	FROM Passenger p
	JOIN Pass_in_trip pt ON p.id_psg = pt.id_psg
	JOIN Trip t ON pt.trip_no = t.trip_no
	JOIN Airline_company a ON t.id_comp = a.id_comp)
SELECT passenger_name, COUNT(trip_no) AS num_flights, company_name
FROM all_data
GROUP BY passenger_name, company_name
HAVING num_flights > 1;
*/