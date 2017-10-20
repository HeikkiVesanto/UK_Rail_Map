--Queries copied from http://spatialdbadvisor.com/postgis_tips_tricks/?pg=9

CREATE TYPE coordtype AS (
    x double precision,
    y double precision,
    z double precision,
    m double precision
);


CREATE TYPE vectortype AS (
    startcoord coordtype,
    endcoord coordtype
);

CREATE OR REPLACE FUNCTION ST_GetVector(p_geometry geometry)
  RETURNS SETOF VectorType IMMUTABLE  
AS $$
DECLARE
    v_GeometryType   varchar(1000);
    v_rec            RECORD;
    v_vector         VectorType;
    v_start          CoordType;
    v_end            CoordType;
    c_points CURSOR ( p_geom         geometry,
                      p_Geometrytype text ) 
    IS
      SELECT ST_X(sp) as sx,ST_Y(sp) as sy,ST_Z(sp) as sz,ST_M(sp) as sm,
             ST_X(ep) as ex,ST_Y(ep) as ey,ST_Z(ep) as ez,ST_M(ep) as em
       FROM ( SELECT ST_PointN(p_geom, generate_series(1, ST_npoints(p_geom)-1)) as sp,
                     ST_PointN(p_geom, generate_series(2, ST_npoints(p_geom)  )) as ep
               WHERE ( p_GeometryType = 'ST_LineString' ) 
            ) AS linestring;
Begin
    If ( p_geometry is NULL ) Then
      return;
    End If;
    v_GeometryType := ST_GeometryType(p_geometry);
    If    ( v_GeometryType in ('ST_Point','ST_MultiPoint') ) Then
      return;
    End If;
    IF ( v_GeometryType = 'ST_Geometry' ) THEN
      -- Could be anything... use native PostGIS function
      v_GeometryType = GeometryType(p_geometry);
      IF ( v_geometryType = 'GEOMETRYCOLLECTION' ) THEN
         FOR v_geom IN 1..ST_NumGeometries(p_geometry) LOOP
            FOR v_rec IN SELECT * FROM ST_GetVector(ST_GeometryN(p_geometry,v_geom)) LOOP
   	        RETURN NEXT v_rec;
   	    END LOOP;
         END LOOP;
      ELSE
         -- Probably CURVED something...
         RETURN;
      END IF;
    END IF;
    IF ( v_geometryType NOT IN ('ST_Geometry','GEOMETRYCOLLECTION') ) THEN
      OPEN c_points(p_geometry,v_Geometrytype);
      LOOP
        FETCH c_points INTO 
              v_start.x, v_start.y, v_start.z, v_start.m,
              v_end.x,   v_end.y,   v_end.z,   v_end.m;
        v_vector.startcoord := v_start;
        v_vector.endcoord   := v_end;
        EXIT WHEN NOT FOUND;
        RETURN NEXT v_vector;
      END LOOP;
      CLOSE c_points;
    END IF;
end;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION ST_GetVectorSQL(p_geometry geometry)
  RETURNS SETOF VectorType IMMUTABLE 
AS
$$
	SELECT * FROM ST_GetVector($1);
$$
LANGUAGE 'sql';




CREATE TABLE public.ukrail_manual_agency_parent
(
  agency_name character varying,
  oid integer NOT NULL DEFAULT nextval('ukrail_manual_agency_parent_oid_seq'::regclass),
  parent_company character varying,
  CONSTRAINT uk_rail_magency_pkey PRIMARY KEY (oid)
);
--This also needs to be populated. ukrail_manual_agency_parent.backup contains a table