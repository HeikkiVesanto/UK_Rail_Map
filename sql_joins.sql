CREATE TABLE ukrail_distinct_agencies AS 
 SELECT DISTINCT ukrail_agency.agency_name
   FROM ukrail_agency;

vacuum analyze ukrail_distinct_agencies;

CREATE TABLE ukrail_distinct_agencies_parent AS 
 SELECT ukrail_distinct_agencies.agency_name, ukrail_manual_agency_parent.parent_company
   FROM ukrail_distinct_agencies, ukrail_manual_agency_parent
WHERE ukrail_distinct_agencies.agency_name = ukrail_manual_agency_parent.agency_name;

vacuum analyze ukrail_distinct_agencies_parent;

CREATE TABLE ukrail_distinct_parent AS 
 SELECT DISTINCT ukrail_manual_agency_parent.parent_company
   FROM ukrail_manual_agency_parent;

vacuum analyze ukrail_distinct_parent;

CREATE TABLE ukrail_stopsgeom AS
SELECT ukrail_stop_times.trip_id, ukrail_stop_times.stop_id, ukrail_stop_times.stop_sequence, ukrail_stops.geom, ukrail_stops.stop_name
FROM ukrail_stops, ukrail_stop_times
WHERE ukrail_stops.stop_id = ukrail_stop_times.stop_id;

vacuum analyze ukrail_stopsgeom;

CREATE TABLE ukrail_lines AS
SELECT stops.trip_id, ST_MakeLine(stops.geom ORDER BY stop_sequence) As geom
FROM ukrail_stopsgeom As stops
GROUP BY stops.trip_id;
CREATE INDEX ukrail_lines_geom_gist ON ukrail_lines USING GIST ( geom );

vacuum analyze ukrail_lines;

CREATE TABLE ukrail_lines_trips AS
SELECT DISTINCT
ukrail_lines.geom, ukrail_routes.route_long_name, ukrail_agency.agency_name
FROM
ukrail_lines,
ukrail_trips,
ukrail_routes,
ukrail_agency
WHERE
ukrail_lines.trip_id = ukrail_trips.trip_id
AND
ukrail_trips.route_id = ukrail_routes.route_id
AND
ukrail_routes.agency_id = ukrail_agency.agency_id
AND
route_type IN ('0','1','2','4','5','6');
vacuum analyze ukrail_lines_trips;

CREATE TABLE ukrail_lines_exploded AS
SELECT ukrail_lines_trips.agency_name, 
       (ST_GetVectorSQL(ukrail_lines_trips.geom)).*
  FROM ukrail_lines_trips;
vacuum analyze ukrail_lines_exploded;
  
CREATE TABLE ukrail_lines_segments AS
SELECT DISTINCT agency_name, ST_SetSRID(ST_MakeLine(ST_MakePoint((startcoord).x,(startcoord).y)::geometry,ST_MakePoint((endcoord).x, (endcoord).y)::geometry),4326) as geom
From ukrail_lines_exploded;
vacuum analyze ukrail_lines_segments;

ALTER TABLE IF EXISTS ukrail_lines_final RENAME  TO ukrail_lines_final_old;

CREATE TABLE ukrail_lines_final AS
SELECT ukrail_lines_segments.agency_name, ukrail_manual_agency_parent.parent_company, ukrail_lines_segments.geom
FROM
ukrail_lines_segments, ukrail_manual_agency_parent
WHERE
ukrail_lines_segments.agency_name = ukrail_manual_agency_parent.agency_name;
vacuum analyze ukrail_lines_final;

