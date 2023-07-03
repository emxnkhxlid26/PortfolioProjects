SELECT *
FROM lap_times
----------------------------------------------------------------

--The fastest lap time for different circuits

-- Joining 4 datasets together
SELECT 
c.country,
c.location,
c.name as CircuitName,
r.year,
CONCAT(d.forename, ' ', d.surname) as Driver,
lt.time
FROM lap_times lt
JOIN races r ON lt.raceId = r.raceID
JOIN circuits c ON c.circuitId = r.circuitId
JOIN drivers d ON lt.driverId = d.driverId

--Want to select the fastest time using Min
SELECT 
c.country,
c.location,
c.name as CircuitName,
r.year,
CONCAT(d.forename, '', d.surname) as Driver,
min(lt.time) as fastest_time
FROM lap_times lt
JOIN races r ON lt.raceId = r.raceID
JOIN circuits c ON c.circuitId = r.circuitId
JOIN drivers d ON lt.driverId = d.driverId
Group by 
c.country,
c.location,
c.name,
r.year,
d.forename, 
d.surname
ORDER BY r.year ASC, min(lt.time) ASC, c.country

--Using subquery for wanting the fastest time
SELECT 
c.country,
c.location,
c.name as CircuitName,
r.year,
CONCAT(d.forename, ' ', d.surname) as Driver,
min(lt.time) as fastest_time
FROM lap_times lt
JOIN races r ON lt.raceId = r.raceID
JOIN circuits c ON c.circuitId = r.circuitId
JOIN drivers d ON lt.driverId = d.driverId
JOIN(
SELECT 
r.circuitId,
MIN(lt.time) as min_time
FROM lap_times lt
JOIN races r ON lt.raceId = r.raceId
GROUP BY r.circuitId) AS subquery on c.circuitId = subquery.circuitId AND lt.time = subquery.min_time
Group by 
c.country,
c.location,
c.name,
r.year,
d.forename, 
d.surname
ORDER By r.year ASC, fastest_time ASC, c.country


-----------------------------------------------------------------
--Contructor titles per team since 1950

-- Constructors standings 

SELECT standings.year, standings.round, standings.circuitid, standings.raceid, standings.name, standings.date, 
       standings.constructorId, standings.points,
       c.constructorId, c.constructorRef, c.name
FROM (
    SELECT t1.year, t1.round, t1.circuitid, t1.raceid, t1.name, t1.date, cs.constructorStandingsId, cs.constructorId, cs.points,
        ROW_NUMBER() OVER (PARTITION BY t1.year ORDER BY t1.round DESC) AS rank
    FROM races t1
    JOIN (
        SELECT raceid, MAX(points) AS max_points
        FROM constructor_standings
        GROUP BY raceid
    ) t2 ON t1.raceid = t2.raceid
    JOIN constructor_standings cs ON t2.raceid = cs.raceid AND t2.max_points = cs.points
) standings
JOIN constructors c ON standings.constructorId = c.constructorId
WHERE standings.rank = 1;

----------------------------------------------------------------------
--Driver champions since 1950

-- select only the last rounds of every year

SELECT t1.year,round, circuitid, raceid, name, date
FROM races t1
JOIN (
    SELECT year, MAX(round) AS max_round
    FROM races
    GROUP BY year
) t2 ON t1.year = t2.year AND t1.round = t2.max_round;

-- Trying to add in driver standings

SELECT year, round, circuitid, raceid, name, date, driverStandingsId, driverId, points
FROM (
    SELECT t1.year, t1.round, t1.circuitid, t1.raceid, t1.name, t1.date, ds.driverStandingsId, ds.driverId, ds.points,
        ROW_NUMBER() OVER (PARTITION BY t1.year ORDER BY ds.points DESC) AS rank
    FROM races t1
    JOIN (
        SELECT raceid, MAX(points) AS max_points
        FROM driver_standings
        GROUP BY raceid
    ) t2 ON t1.raceid = t2.raceid
    JOIN driver_standings ds ON t2.raceid = ds.raceid AND t2.max_points = ds.points
) standings
WHERE rank = 1;

-- adding driver names to this

SELECT standings.year, standings.round, standings.circuitid, standings.raceid, standings.name, standings.date, 
standings.driverId, standings.points,
       d.driverId, d.driverRef,d.forename, d.surname
FROM (
    SELECT t1.year, t1.round, t1.circuitid, t1.raceid, t1.name, t1.date, ds.driverStandingsId, ds.driverId, ds.points,
        ROW_NUMBER() OVER (PARTITION BY t1.year ORDER BY ds.points DESC) AS rank
    FROM races t1
    JOIN (
        SELECT raceid, MAX(points) AS max_points
        FROM driver_standings
        GROUP BY raceid
    ) t2 ON t1.raceid = t2.raceid
    JOIN driver_standings ds ON t2.raceid = ds.raceid AND t2.max_points = ds.points
) standings
JOIN drivers d ON standings.driverId = d.driverId
WHERE standings.rank = 1;


----------------------------------------------------------------
--Correlation between qualifying position and raceResult position
SELECT
 r.name AS Race,
 r.year AS Year,
 c.name AS ConstructorName,
 CONCAT(d.forename, ' ', d.surname) AS DriverName,
 q.position AS QualifyingPosition,
 re.position AS RacePosition
FROM
 races r
JOIN
results re ON re.raceId = r.raceId
JOIN
constructors c ON c.constructorId = re.constructorId
JOIN
drivers d ON d.driverId = re.driverId
JOIN
qualifying q ON q.raceId = r.raceId AND q.driverId = re.driverId

WHERE re.position is NOT NULL
ORDER BY
    r.year ASC;

	--New column to show difference
SELECT
 r.name AS Race,
 r.year AS Year,
 c.name AS ConstructorName,
 CONCAT(d.forename, ' ', d.surname) AS DriverName,
 q.position AS QualifyingPosition,
 re.position AS RacePosition,
CASE
WHEN q.position < re.position THEN re.position - q.position
WHEN q.position > re.position THEN  -(q.position - re.position) 
ELSE 0
END AS PositionDifference
FROM
 races r
JOIN
results re ON re.raceId = r.raceId
JOIN
constructors c ON c.constructorId = re.constructorId
JOIN
drivers d ON d.driverId = re.driverId
JOIN
qualifying q ON q.raceId = r.raceId AND q.driverId = re.driverId

WHERE re.position is NOT NULL
ORDER BY
    r.year ASC;



