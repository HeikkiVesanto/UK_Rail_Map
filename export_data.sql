\copy (SELECT * FROM ukrail_distinct_agencies) TO 'ukrail_distinct_agencies.csv' DELIMITER ',' CSV;
\copy (SELECT * FROM ukrail_distinct_agencies_parent ORDER BY agency_name) TO 'ukrail_distinct_agencies_parent.csv' DELIMITER ',' CSV HEADER;
\copy (SELECT * FROM ukrail_distinct_parent) TO 'ukrail_distinct_parent.csv' DELIMITER ',' CSV;