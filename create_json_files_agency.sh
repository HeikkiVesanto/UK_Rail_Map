while read LAYER
do

FOO=$LAYER
FOO_NO_WHITESPACE="$(echo -e "${FOO}" | tr -cd '[[:alnum:]]')"
    /usr/bin/ogr2ogr -f GeoJSON agencies_js/$FOO_NO_WHITESPACE.js -lco COORDINATE_PRECISION=4 -sql "select agency_name, parent_company, geom FROM ukrail_lines_final WHERE agency_name = '$LAYER'" pg:"dbname='gis' user='tseepra' password='postgres' host='localhost'" ukrail_lines_final
done < 'ukrail_distinct_agencies.csv'