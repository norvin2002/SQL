CREATE TABLE individual_info
(
year integer,
case_individual_id integer,
case_vehicle_id integer,
victim_status text,
role_type text,
seating_position text,
ejection text,
license_state_code text,
sex text,
transported_by text,
safety_equipment text,
injury_descriptor text,
injury_location text,
injury_severity text,
age integer
)

WITH (
  OIDS = FALSE
)
;
ALTER TABLE individual_info
OWNER TO postgres;
GRANT ALL ON TABLE individual_info TO postgres;
GRANT SELECT ON TABLE individual_info to postgres;