# UK_Rail_Map
Map of the uk rail network. Can run weekly to take into account any changes.

This is very poorly documented.

This esentailly creates all the files in one folder and then copies the html and js ones to a different one.

Queries from:
sql_queries_neededing_to_be_created.sql

Need to be run first.

And the public.ukrail_manual_agency_parent table needs to be created. This will contain the logic between the parent company and the operator.

The file in ukrail_manual_agency_parent.backup was accurate in 2017.

The GTFS files used the generate the map are no longer updated by ATOC. So this will no longer run correctly. But could be modified for other countries.