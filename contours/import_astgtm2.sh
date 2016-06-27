#!/bin/bash

##  ======================================================================================== ##
##  file:  import_ASTGTM2.sh                                          Author: ikcalB
##  --------------------------
##  
##  import *ASTER_GDEM v2* into postgis databse
##  (utilize  "man <command>"  if you need help)
##
##                                                      /-  ASTGTM2_N##E###_dem.tif
##  data-STRUCTURE:             ASTGTM2_N##E###.zip     --  ASTGTM2_N##E###_num.tif
##                                                      \-  README.pdf
##
##  (example for Northern hemisphere,                   *FURTHER information in README.pdf*
##   to the east of greenwich)
##  ======================================================================================== ##

PREP_TABLE="1"                          #  initialize table?
TABLE="contours"                        #  table name for insertion
NODATA_VAL="-9999"                      #  ASTER_GDEM v2 nodata-vale 
                                        #+ (according to README.pdf inside each .zip-archive)
INTERVAL="10"                           #  METERS (Resolution for contour-lines) 
COLUMN="height"                         #  column name for height-information
GEOMETRY="geometry"                     #  column name for geometry-information

OPTIONS="-q -d gis -U sliu"         #  postgresql options: quiet, db-name, username

for FILE in *.zip
do
        # unzip
        unzip "$FILE" -x "*_num.tif" "README.pdf"

        #  sanitize filename for further use
        FILE="${FILE%%.zip}"

        # import contours
        gdal_contour -i $INTERVAL -snodata $NODATA_VAL -a $COLUMN "${FILE}_dem.tif" "${FILE}.shp"

        # prepare database (executed only once)
        [ "$PREP_TABLE" ] && shp2pgsql -p -I -g $GEOMETRY "${FILE}.shp" $TABLE | psql $OPTIONS
        unset PREP_TABLE

        # append data to table
        shp2pgsql -a -g $GEOMETRY "${FILE}.shp" $TABLE | psql $OPTIONS

        # clean up
        rm "${FILE}_dem.tif"                            # extracted ASTER_GDEM file
        rm "${FILE}.shp"                                # computed shape file
        rm "${FILE}.dbf" "${FILE}.shx" "${FILE}.prj"   # shapefile information
done

echo
echo "DONE"

exit 0