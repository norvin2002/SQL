CREATE TABLE case_info
(
year integer,
crash_descriptor text,
"time" time,
"date" text,
day_of_week text,
police_report text,
lighting_conditions text,
municipality text,
collision_type_descriptor text,
county_name text,
road_descriptor text,
weather_conditions text,
traffic_control_device text,
road_surface_conditions text,
dot_reference_marker_location text,
pedestrian_bicyclist_action text,
event_descriptor text,
number_of_vehicles_involved text
)

WITH (
  OIDS = FALSE
)
;
ALTER TABLE case_info
OWNER TO postgres;
GRANT ALL ON TABLE case_info TO postgres;
GRANT SELECT ON TABLE case_info to postgres;