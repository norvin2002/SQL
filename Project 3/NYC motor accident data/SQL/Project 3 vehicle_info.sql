CREATE TABLE vehicle_info
(
year integer,
case_vehicle_id integer,
vehicle_body_type text,
registration_class text,
action_prior_to_accident text,
type_axles_of_truck_or_bus text,
direction_of_travel text,
fuel_type text,
vehicle_year integer,
state_of_registration text,
number_of_occupants integer,
engine_cylinders integer,
vehicle_make text,
contributing_factor_1 text,
contributing_factor_1_description text,
contributing_factor_2 text,
contributing_factor_2_description text,
event_type text,
partial_vin text
)

WITH (
  OIDS = FALSE
)
;
ALTER TABLE vehicle_info
OWNER TO postgres;
GRANT ALL ON TABLE vehicle_info TO postgres;
GRANT SELECT ON TABLE vehicle_info to postgres;