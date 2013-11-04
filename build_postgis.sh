# Stop if anything goes awry
set -e

source versions.sh

########################################################################
# Prepare the PostGIS source

POSTGIS_NAME=postgis-${V_POSTGIS}
if [ ! -f ${SOURCES}/${POSTGIS_NAME}.tar.gz ]; then
  wget -O ${SOURCES}/${POSTGIS_NAME}.tar.gz http://download.osgeo.org/postgis/source/${POSTGIS_NAME}.tar.gz
fi
cd ${BUILDS}
tar -xvf ${SOURCES}/${POSTGIS_NAME}.tar.gz
cd ${POSTGIS_NAME}

########################################################################
# ENVIRONMENT

PATH=/bin:/sbin:/include:/c/Windows/system32
for PREFIX in $PREFIXES $BUILDCHAIN
do
  if [ ! -d ${PREFIX} ]; then
    echo "Missing expected dependency $PREFIX"
	exit 1
  fi
  PATH=$PREFIX/bin:$PREFIX/lib:$PATH
done

echo $PATH
export PATH

export GDAL_DATA=${PREFIX_GDAL}/share/gdal

########################################################################
# CONFIGURE

LDFLAGS="-L${PREFIX_PGSQL}/lib" \
./configure \
  --target=${MINGHOST} \
  --with-xml2config=${PREFIX_LIBXML}/bin/xml2-config \
  --with-pgconfig=${PREFIX_PGSQL}/bin/pg_config \
  --with-geosconfig=${PREFIX_GEOS}/bin/geos-config \
  --with-projdir=${PREFIX_PROJ} \
  --with-gdalconfig=${PREFIX_GDAL}/bin/gdal-config \
  --with-jsondir=${PREFIX_JSON} \
  --with-libiconv=${PREFIX_LIBICONV} \
  --with-gui \
  --with-gettext=no
	  
	#    --with-xsldir=${PROJECTS}/docbook/docbook-xsl-1.76.1 

########################################################################
# BUILD

make && make install



