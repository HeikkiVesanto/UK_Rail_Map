#!b/bin/bash
#Add paths to run properly through cron
cd /home/username/files/rail_maps_automated
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1
/bin/rm /home/username/files/rail_maps_automated/*.txt
/bin/rm /home/username/files/rail_maps_automated/*.csv
#/bin/rm /home/username/files/rail_maps_automated/gtfs.zip
#URL now broken
#/usr/bin/curl 'http://www.gbrail.info/gtfs.zip' -o gtfs.zip
/usr/bin/unzip -o gtfs.zip
/bin/mv stops.txt stops.csv
echo "Time: $(date) Step 1" > logging.txt
PGPASSWORD=pg_pw /usr/bin/psql -U username -d gis -h localhost -p 5432 -a -f 'drop_table.sql'
PGPASSWORD=pg_pw /usr/bin/psql -U username -d gis -h localhost -p 5432 -a -f 'create_tables.sql'
PGPASSWORD=pg_pw /usr/bin/psql -U username -d gis -h localhost -p 5432 -a -f 'copy_data.sql'
/usr/bin/ogr2ogr -f Postgresql pg:"dbname='gis' user='username' password='pg_pw' host='localhost'" -lco GEOMETRY_NAME=geom -lco PRECISION=no -nlt POINT -skipfailures -a_srs EPSG:4326 -nln "ukrail_stops" 'stops.vrt'
PGPASSWORD=pg_pw /usr/bin/psql -U username -d gis -h localhost -p 5432 -a -f 'vacuum_analyze.sql'
PGPASSWORD=pg_pw /usr/bin/psql -U username -d gis -h localhost -p 5432 -a -f 'sql_joins.sql'
PGPASSWORD=pg_pw /usr/bin/psql -U username -d gis -h localhost -p 5432 -a -f 'export_data.sql'
/bin/rm *.txt
/bin/rm dynamic_js/*.js
/usr/bin/ogr2ogr -f GeoJSON dynamic_js/stops.js -lco COORDINATE_PRECISION=4 -sql "SELECT DISTINCT ON (stop_name) stop_name, geom FROM ukrail_stopsgeom ORDER BY stop_name, stop_id DESC" pg:"dbname='gis' user='username' password='postgres' host='localhost'" ukrail_stops
echo "Time: $(date) Step 2" >> logging.txt
/bin/rm agencies_js/*.js
/bin/rm parent_js/*.js
/bin/bash create_json_files_agency.sh
/bin/bash create_json_files_parent.sh
/bin/bash add_json_headers_agencies.sh
/bin/bash add_json_headers_parent.sh
/bin/bash add_json_headers_dynamic_js.sh
/bin/ls parent_js > parent.txt
/bin/ls agencies_js > agencies.txt
/bin/rm agencies.html
/bin/rm parent.html
/usr/bin/python rail_HTML_generator.py -i agencies
/usr/bin/python rail_HTML_generator.py -i parent
/usr/bin/python rail_HTML_generator_mobile.py -i agencies
/usr/bin/python rail_HTML_generator_mobile.py -i parent
/bin/cp /var/www/ukrailmap.co.uk/html/* /home/username/files/rail_maps_automated/www_backup
/bin/cp /home/username/files/rail_maps_automated/agencies.html /home/username/files/rail_maps_automated/parent.html /home/username/files/rail_maps_automated/ukrail_distinct_agencies_parent.html /home/username/files/rail_maps_automated/agencies_mobile.html /home/username/files/rail_maps_automated/parent_mobile.html /home/username/files/rail_maps_automated/ukrail_distinct_agencies_parent.csv /var/www/ukrailmap.co.uk/html/
echo "Time: $(date) Step 3" >> logging.txt
/bin/rm /var/www/ukrailmap.co.uk/html/agencies_js/*
/bin/cp /home/username/files/rail_maps_automated/agencies_js/* /var/www/ukrailmap.co.uk/html/agencies_js/
/bin/rm /var/www/ukrailmap.co.uk/html/css/*
/bin/cp -r /home/username/files/rail_maps_automated/css/* /var/www/ukrailmap.co.uk/html/css/
/bin/rm /var/www/ukrailmap.co.uk/html/dynamic_js/*
/bin/cp /home/username/files/rail_maps_automated/dynamic_js/* /var/www/ukrailmap.co.uk/html/dynamic_js/
/bin/rm /var/www/ukrailmap.co.uk/html/js/*
/bin/cp /home/username/files/rail_maps_automated/js/* /var/www/ukrailmap.co.uk/html/js/
/bin/rm /var/www/ukrailmap.co.uk/html/parent_js/*
/bin/cp /home/username/files/rail_maps_automated/parent_js/* /var/www/ukrailmap.co.uk/html/parent_js/
/bin/rm /var/www/ukrailmap.co.uk/html/static_js/*
/bin/cp /home/username/files/rail_maps_automated/static_js/* /var/www/ukrailmap.co.uk/html/static_js/
echo "Time: $(date) Step 4 - Done" >> logging.txt