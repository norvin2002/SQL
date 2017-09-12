-- Identify accident trends


-- Number of accident by year and crash description
SELECT year, crash_descriptor, COUNT(crash_descriptor)
FROM case_info
GROUP BY year, crash_descriptor
ORDER BY year, crash_descriptor
;

-- Number of accident by year and collision_type_descriptor
SELECT year, collision_type_descriptor, COUNT (collision_type_descriptor)
FROM case_info
GROUP BY year, collision_type_descriptor
ORDER BY year, collision_type_descriptor
;

-- Count of accident by day of the week, grouped by year
SELECT year, day_of_week, COUNT (collision_type_descriptor)::NUMERIC
FROM case_info
GROUP BY year, day_of_week
ORDER BY year, day_of_week
;

-- Accident count by weather by year
SELECT year, weather_conditions, COUNT(weather_conditions)
FROM case_info
GROUP BY year, weather_conditions
ORDER BY year, weather_conditions
;

-- Count of victim status
SELECT year, victim_status, COUNT (victim_status)
FROM individual_info
GROUP BY year, victim_status
;

-- Try to understand the structure of the data. checked if Individual_id can have duplicate
SELECT case_individual_id, COUNT (case_individual_id) AS indv_count
FROM individual_info
GROUP BY case_individual_id
HAVING COUNT (case_individual_id) > 1
ORDER BY indv_count
;

-- Identify duplicate Case_individual_id
SELECT *
FROM individual_info
WHERE case_individual_id IN
	(

	SELECT case_individual_id
	FROM individual_info
	GROUP BY case_individual_id
	HAVING COUNT (case_individual_id) > 1
	)
ORDER BY case_individual_id
;

-- Count of Accident type (PD, BI, PDBI, Fatal)
SELECT year, crash_descriptor, COUNT (crash_descriptor)
FROM case_info
GROUP BY year, crash_descriptor
ORDER BY year, crash_descriptor
;

-- COUNT of incident by violation code and year (Most common kind of accident)
SELECT year, violation_code, violation_description, COUNT (case_individual_id) AS incident_count
FROM violation_info
GROUP BY year, violation_code, violation_description
ORDER BY year, incident_count DESC
;

-- Count of Drink Driving Incident by year
SELECT year, violation_code, violation_description, COUNT (case_individual_id) AS incident_count, (COUNT (case_individual_id)::NUMERIC/
	(SELECT COUNT (*)
	FROM violation_info
	) :: NUMERIC
	) AS ratio_of_total_incident
FROM violation_info
WHERE violation_code = '11923'
GROUP BY year, violation_code, violation_description
ORDER BY year, incident_count DESC
;

-- Count of Alcohol Related Incident by year
SELECT year, COUNT (case_individual_id) AS incident_count, (COUNT (case_individual_id)::NUMERIC/
	(SELECT COUNT (*)
	FROM violation_info
	) :: NUMERIC
	) AS ratio_of_total_incident
FROM violation_info
WHERE violation_description ILIKE '%ALC%'
GROUP BY year
ORDER BY year

-- ALCOHOL VS NON ALCOHOL INCIDENT
SELECT year, 
	CASE
		WHEN violation_description ILIKE '%ALC%' THEN 'ALCOHOL'
		ELSE 'NON-ALCOHOL'
	END AS alco		
	,COUNT (case_individual_id) AS incident_count, (COUNT (case_individual_id)::NUMERIC/
	(SELECT COUNT (*)
	FROM violation_info
	) :: NUMERIC
	) AS ratio_of_total_incident
FROM violation_info
WHERE violation_description IS NOT NULL
GROUP BY year, alco
ORDER BY year
;

-- Count violation by year and ratio
WITH annual_count AS
(SELECT year, COUNT(*) AS yearly_total
FROM violation_info
GROUP BY year
)

SELECT year, violation_code, violation_description, COUNT (case_individual_id) AS incident_count, 
	(COUNT (case_individual_id) / 
		(SELECT yearly_total
		FROM annual_count
		WHERE annual_count.year = violation_info.year
		):: NUMERIC
	)AS ratio
FROM violation_info
GROUP BY year, violation_code, violation_description
ORDER BY year, incident_count DESC
;


-- LEFT JOIN violation_info with individual_info
SELECT *
FROM violation_info vi LEFT JOIN individual_info ii ON vi.case_individual_id = ii.case_individual_id
ORDER BY vi.year, vi.case_individual_id DESC
;

-- COUNT of Collision type descriptor by year
SELECT year, collision_type_descriptor, COUNT (collision_type_descriptor) AS case_count
FROM case_info
GROUP BY year, collision_type_descriptor
ORDER BY year, case_count DESC
;

-- COUNT of event_descriptor by year
SELECT year, event_descriptor, COUNT (event_descriptor) AS case_count
FROM case_info
GROUP BY year, event_descriptor
ORDER BY year, case_count DESC
;

-- Accident count by day of week
SELECT year, day_of_week, COUNT (event_descriptor)
FROM case_info
GROUP BY year, day_of_week
ORDER BY year, day_of_week
;

-- Accident count by day of week
	WITH count_by_date AS
	(
	SELECT year, date, day_of_week, COUNT(date) AS incident_count
	FROM case_info
	GROUP BY year, date, day_of_week
	ORDER BY year, date, day_of_week
	)

	--Average incident count by day of week
	SELECT year, day_of_week, ROUND(AVG (incident_count)) AS avg_incident_count
	FROM count_by_date
	GROUP BY year, day_of_week
	ORDER BY year, day_of_week
;

-- Accident count by day of week and hour
	WITH count_by_date AS
	(
	SELECT year, date, day_of_week, date_part('hour', time) AS hour, COUNT(date) AS incident_count
	FROM case_info
	WHERE date_part('hour', time) IS NOT NULL
	GROUP BY year, date, hour, day_of_week
	ORDER BY year, date, day_of_week
	)

	--Average incident count by day of week
	SELECT year, day_of_week, hour, SUM(incident_count), ROUND(AVG (incident_count)) AS avg_incident_count
	FROM count_by_date
	GROUP BY year, day_of_week, hour
	ORDER BY year, day_of_week, hour
--
	
-- LEFT JOIN violation_info and Individual_info for Alcohol related offences
SELECT *
FROM violation_info vi LEFT JOIN individual_info ii ON vi.case_individual_id = ii.case_individual_id
WHERE vi.violation_description ILIKE '%ALC%'
-- GROUP BY year, case_individual_id
ORDER BY vi.year
;

-- SEVERITY OF ALCOHOL RELATED OFFENCES
SELECT vi.year, ii.injury_severity, COUNT (ii.injury_severity)
FROM violation_info vi LEFT JOIN individual_info ii ON vi.case_individual_id = ii.case_individual_id
WHERE vi.violation_description ILIKE '%ALC%'
GROUP BY vi.year, ii.injury_severity
ORDER BY vi.year
;

-- SEVERITY OF NON ALCOHOL RELATED OFFENCES
SELECT vi.year, ii.injury_severity, COUNT (ii.injury_severity)
FROM violation_info vi LEFT JOIN individual_info ii ON vi.case_individual_id = ii.case_individual_id
WHERE vi.violation_description NOT ILIKE '%ALC%' AND ii.injury_severity IS NOT NULL
GROUP BY vi.year, ii.injury_severity
ORDER BY vi.year
;

-- SEVERITY OF ALCOHOL vs NON ALCOHOL Incidents
WITH violation_info_grouped AS
(
SELECT *, 
	CASE
		WHEN violation_description ILIKE '%ALC%' THEN 'ALCOHOL'
		ELSE 'NON-ALCOHOL'
	END AS alco		
	
FROM violation_info
WHERE violation_description IS NOT NULL
-- GROUP BY year, alco
-- ORDER BY year
)

SELECT vig.year, vig.alco, ii.injury_severity, COUNT (ii.injury_severity)
FROM violation_info_grouped vig LEFT JOIN individual_info ii ON vig.case_individual_id = ii.case_individual_id
WHERE ii.injury_severity IS NOT NULL
GROUP BY vig.year, vig.alco, ii.injury_severity
ORDER BY vig.year
;

-- COUNT of PEDESTRIAN BICYCLIST INCIDENT BY YEAR
WITH PBSTCOUNT AS
(
SELECT year,
	CASE
		WHEN pedestrian_bicyclist_action LIKE '%Not Applicable%' OR pedestrian_bicyclist_action LIKE '%Unknown%' OR pedestrian_bicyclist_action LIKE '%Not Entered%' THEN 'NON-PB'
		WHEN pedestrian_bicyclist_action NOT LIKE '%Not Applicable%' AND pedestrian_bicyclist_action NOT LIKE '%Unknown%' AND pedestrian_bicyclist_action NOT LIKE '%Not Entered%' THEN 'PB'
	END AS PBST
FROM case_info
)

SELECT year, PBST, COUNT (PBST) AS COUNT
FROM PBSTCOUNT
GROUP BY year, PBST
ORDER BY year
;

-- CORRELATION BETWEEN SEATING POSITION AND INJURY SEVERITY
SELECT year, seating_position, injury_severity, COUNT(injury_severity) AS victim_count
FROM individual_info
GROUP BY year, seating_position, injury_severity
ORDER BY year, seating_position, injury_severity DESC
;

-- CORRELATION BETWEEN SEATING POSITION, SAFETY EQUIPMENT AND INJURY SEVERITY
SELECT year, seating_position, safety_equipment, injury_severity, COUNT(injury_severity) AS victim_count
FROM individual_info
GROUP BY year, seating_position, safety_equipment, injury_severity
ORDER BY year, seating_position, injury_severity DESC
;

-- CORRELATION BETWEEN SEATING POSITION, SAFETY EQUIPMENT AND EJECTION
SELECT year, seating_position, safety_equipment, injury_severity, ejection, COUNT(injury_severity) AS victim_count
FROM individual_info
GROUP BY year, seating_position, safety_equipment, injury_severity, ejection
ORDER BY year, seating_position, injury_severity DESC, ejection
;

-- CORRELATION BETWEEN AGE AND INJURY SEVERITY (46906 empty age cell vs total record count of 2,233,917 / 2.1% of total)
SELECT year, age, CASE
	WHEN age <= 18 THEN 'CHILD'
	WHEN age BETWEEN 19 AND 30 THEN 'YOUNG'
	WHEN age BETWEEN 31 AND 55 THEN 'MATURE'
	WHEN age > 55 THEN 'SENIOR'
	END AS age_group,
	injury_severity
	-- , COUNT (injury_severity)
FROM individual_info
-- GROUP BY year, age_group, injury_severity
ORDER BY year, age DESC
;

-- CORRELATION BETWEEN AGE AND INJURY SEVERITY GROUPED BY AGE BAND
SELECT year, CASE
	WHEN age <= 18 THEN 'CHILD'
	WHEN age BETWEEN 19 AND 30 THEN 'YOUNG'
	WHEN age BETWEEN 31 AND 55 THEN 'MATURE'
	WHEN age > 55 THEN 'SENIOR'
	END AS age_group,
	injury_severity
	, COUNT (injury_severity) AS victim_count
FROM individual_info
WHERE age IS NOT NULL
GROUP BY year, age_group, injury_severity
ORDER BY year, age_group, victim_count DESC
;