\copy ukrail_agency FROM 'agency.txt' DELIMITER ',' CSV HEADER;
\copy ukrail_routes FROM 'routes.txt' DELIMITER ',' CSV HEADER;
\copy ukrail_trips FROM 'trips.txt' DELIMITER ',' CSV HEADER;
\copy ukrail_stop_times FROM 'stop_times.txt' DELIMITER ',' CSV HEADER;