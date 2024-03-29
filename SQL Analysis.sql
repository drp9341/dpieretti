```NOTE: Here I created a new table taking out all the trips where it was maintenance. ``` 
----------------------------------------------------------------------------------------------------

WITH cleaned_combined_tripdata AS ( 
  SELECT *
  FROM `capstone_2111_2204.combined_tripdata`
  WHERE
    start_station_name <> 'DIVVY CASSETTE REPAIR MOBILE STATION' AND
    start_station_name <> 'Lyft Driver Center Private Rack' AND 
    start_station_name <> '351' AND 
    start_station_name <> 'Base - 2132 W Hubbard Warehouse' AND 
    start_station_name <> 'Hubbard Bike-checking (LBS-WH-TEST)' AND 
    start_station_name <> 'WEST CHI-WATSON' AND 
    end_station_name <> 'DIVVY CASSETTE REPAIR MOBILE STATION' AND
    end_station_name <> 'Lyft Driver Center Private Rack' AND 
    end_station_name <> '351' AND 
    end_station_name <> 'Base - 2132 W Hubbard Warehouse' AND 
    end_station_name <> 'Hubbard Bike-checking (LBS-WH-TEST)' AND 
    end_station_name <> 'WEST CHI-WATSON'
)


----------------------------------------------------------------------------------------------------
```I was left with... 1,089,896 rows.```
----------------------------------------------------------------------------------------------------

I created a new table so I could get a column with the information... "length of ride minutes"

CREATE TABLE `capstone_2111_2204.cleaned_combined_tripdata_new`
AS (
  SELECT *, TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS length_of_ride_minutes
  FROM `capstone_2111_2204.cleaned_combined_tripdata`
);

----------------------------------------------------------------------------------------------------
```Then I created a table based on the types of riders each month to see what the relation was.```
----------------------------------------------------------------------------------------------------

WITH rides_per_month AS
(
   SELECT FORMAT_TIMESTAMP('%B', started_at) AS month, 
          SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS member_rides,
          SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS casual_rides
   FROM `capstone_2111_2204.cleaned_combined_tripdata_new`
   GROUP BY month
)
SELECT *
FROM rides_per_month;

----------------------------------------------------------------------------------------------------
```Then I created a table based on the days of the week vs. type of rider.```
----------------------------------------------------------------------------------------------------

WITH rides_per_day_of_week AS (
  SELECT
    FORMAT_TIMESTAMP('%A', started_at) AS day_of_week,
    AVG(CASE WHEN member_casual = 'member' THEN TIMESTAMP_DIFF(ended_at, started_at, MINUTE) END) AS member_avg_ride_time,
    AVG(CASE WHEN member_casual = 'casual' THEN TIMESTAMP_DIFF(ended_at, started_at, MINUTE) END) AS casual_avg_ride_time
  FROM
    `capstone_2111_2204.cleaned_combined_tripdata_new`
  GROUP BY
    day_of_week
)
SELECT
  day_of_week,
  member_avg_ride_time,
  casual_avg_ride_time
FROM
  rides_per_day_of_week;
