CREATE TABLE violation_info
(
year integer,
violation_description text,
violation_code text,
case_individual_id integer
)

WITH (
  OIDS = FALSE
)
;
ALTER TABLE violation_info
OWNER TO postgres;
GRANT ALL ON TABLE violation_info TO postgres;
GRANT SELECT ON TABLE violation_info to postgres;