## Daniel Pieretti's Portfolio
```To create a comprehensive table containing all bike trips from November 1st, 2021, to April 31, 2022,
we will append or union the data from the 6 monthly bike trip tables.```

     
CREATE TABLE bike_tripdata_21_22.combined_tripdata
SELECT *
FROM (
     SELECT * FROM `capstone_2111_2204.cyclistic_2111`
     UNION ALL 
     SELECT * FROM `capstone_2111_2204.cyclistic_2112`
     UNION ALL 
     SELECT * FROM `capstone_2111_2204.cyclistic_2201`
     UNION ALL 
     SELECT * FROM `capstone_2111_2204.cyclistic_2202`
     UNION ALL 
     SELECT * FROM `capstone_2111_2204.cyclistic_2203`
     UNION ALL 
     SELECT * FROM `capstone_2111_2204.cyclistic_2204`
     );
     
```Above 'SELECT *' query returned 1,482,188 rows. 
The sum off all 12 table's rows is the same, thus we know the table was created correctly.
We should expect the rows from the 12 seperate tables to equal the appended table as we used a UNION ALL.
A UNION ALL keeps all the rows from the multiple tables specified in the UNION ALL OR appends them.
However, a UNION will remove all rows that have duplicate values in one of the table's you are unioning.

--#1. Analyze all columns from left to right for cleaning
ride_id:
- check length combinations for ride_id  
- and all values are unique as ride_id is a primary key```


SELECT LENGTH(ride_id), count(*)
FROM `capstone_2111_2204.combined_tripdata`
GROUP BY LENGTH(ride_id);

SELECT COUNT (DISTINCT ride_id)
FROM `capstone_2111_2204.combined_tripdata`>
     
``` NOTES
The 'ride_id' column consists of unique 16-character long strings. No data cleaning is required for this column.

--#2. check the allowable rideable_types
----------------------------------------------------------------------------------------------------```

SELECT DISTINCT rideable_type
FROM `capstone_2111_2204.combined_tripdata`;
     
```---NOTES:--------------------------------------------------------------------------------------------
As observed earlier, there are three categories of 'rideable_type': electric_bike, classic_bike, and docked_bike. However, it appears that the designation "docked_bike" is an incorrect label and should be updated to "classic_bike".
----------------------------------------------------------------------------------------------------```


```#3. Verify the started_at and ended_at columns.
We are interested in selecting rows where the duration of the ride was more than one minute but less than one day.```

SELECT *
FROM `capstone_2111_2204.combined_tripdata`
WHERE TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1 OR
   TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1440;

``` #4. Validate the start/end station name/id columns for naming inconsistencies.```

-- Query 1: Count the occurrences of each start station name.
SELECT start_station_name, count(*)
FROM capstone_2111_2204.combined_tripdata
GROUP BY start_station_name
ORDER BY start_station_name;

-- Query 2: Count the occurrences of each end station name.
SELECT end_station_name, count(*)
FROM capstone_2111_2204.combined_tripdata
GROUP BY end_station_name
ORDER BY end_station_name;

-- Query 3: Calculate the count of distinct start/end station names and station IDs.
SELECT COUNT(DISTINCT start_station_name) AS unq_startname,
COUNT(DISTINCT end_station_name) AS unq_endname,
COUNT(DISTINCT start_station_id) AS unq_startid,
COUNT(DISTINCT end_station_id) AS unq_endid
FROM capstone_2111_2204.combined_tripdata;

/*
The start and end station names require cleanup:

Remove leading and trailing spaces.
Remove the substring '(Temp)' as Cyclistic uses it during station repairs. All station names should adhere to the same naming conventions.
We found instances of start/end names such as "DIVVY CASSETTE REPAIR MOBILE STATION", "Lyft Driver Center Private Rack", "351", "Base - 2132 W Hubbard Warehouse", Hubbard Bike-checking (LBS-WH-TEST), and "WEST CHI-WATSON". These will be deleted as they represent maintenance trips.
The start and end station ID columns have numerous naming convention errors and varying string lengths. Since they do not provide any value to the analysis and do not benefit from cleaning, they will be disregarded.
*/
#5. Check for NULLs in the start and end station name columns.

SELECT rideable_type, count(*) as num_of_rides
FROM capstone_2111_2204.combined_tripdata
WHERE start_station_name IS NULL AND start_station_id IS NULL
OR end_station_name IS NULL AND end_station_id IS NULL
GROUP BY rideable_type;

/*
For classic bikes and docked bikes, trips always start and end with the bikes locked in a docking station. However, electric bikes offer more flexibility, as they can be locked using their bike lock in the general vicinity of a docking station. Therefore, electric bike trips may not necessarily start or end at a station. To address this:

Remove classic/docked bike trips that lack a start or end station name and do not have a start/end station ID to fill in the null values.
Change the null station names to 'On Bike Lock' for electric bikes.
*/
--#6. Verify rows where latitude and longitude values are null.

SELECT *
FROM capstone_2111_2204.combined_tripdata
WHERE start_lat IS NULL OR
start_lng IS NULL OR
end_lat IS NULL OR
end_lng IS NULL;

-- NOTE: We will exclude these rows as all rows should have location points.

#7. Confirm that there are only two member types in the member_casual column.

SELECT DISTINCT member_casual
FROM capstone_2111_2204.combined_tripdata

-- NOTE: There are only two! Good!
