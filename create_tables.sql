CREATE TABLE ukrail_agency
(
  agency_id character varying,
  agency_name character varying,
  agency_url character varying,
  agency_timezone character varying,
  agency_lang character varying,
  agency_phone character varying
);

CREATE TABLE ukrail_routes
(
  route_id character varying,
  agency_id character varying,
  route_short_name character varying,
  route_long_name character varying,
  route_type character varying
);

CREATE TABLE ukrail_trips
(
  route_id character varying,
  service_id character varying,
  trip_id integer,
  wheelchair_accessible character varying,
bikes_allowed character varying,
train_uid character varying,
train_status character varying,
train_category character varying,
train_identity character varying,
headcode character varying,
train_service_code character varying,
portion_id character varying,
power_type character varying,
timing_load character varying,
speed character varying,
oper_chars character varying,
train_class character varying,
sleepers character varying,
reservations character varying,
catering character varying,
service_branding character varying,
stp_indicator character varying,
uic_code character varying,
atoc_code character varying,
applicable_timetable character varying
);

CREATE TABLE ukrail_stop_times
(
  trip_id integer,
  arrival_time character varying,
  departure_time character varying,
  stop_id character varying,
  stop_sequence integer,
  pickup_type character varying,
drop_off_type character varying,
wtt_arrival_time character varying,
wtt_departure_time character varying,
platform character varying,
line character varying,
path character varying,
activity character varying,
engineering_allowance character varying,
pathing_allowance character varying,
performance_allowance character varying
);

