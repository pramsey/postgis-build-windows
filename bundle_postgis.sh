# This bundles our own version of PgSQL with PostGIS
# and all the required DLLs for the server components.
# This does not bundle the GTK components required for
# the GUI loader.
# Final bundler should bundle only files needed for
# copying into the existing EDB directory structure

set -e

source versions.sh

PATH=/bin:/sbin:/include:/c/Windows/system32
for PREFIX in $PREFIXES $BUILDCHAIN
do
  if [ ! -d ${PREFIX} ]; then
    echo "Missing expected dependency $PREFIX"
	exit 1
  fi
done

echo $PATH
export PATH

BUNDLE=${RELEASES}/bundle/pgsql-${V_PGSQL_MAJOR}-${V_POSTGIS_MAJOR}

if [ ! -d ${BUNDLE} ]; then
	mkdir -p ${BUNDLE}
fi

cp -r ${PREFIX_PGSQL}/* ${BUNDLE}
cp ${PREFIX_GDAL}/bin/* ${BUNDLE}/bin
cp ${PREFIX_GEOS}/bin/* ${BUNDLE}/bin
cp ${PREFIX_LIBICONV}/bin/* ${BUNDLE}/bin
cp ${PREFIX_LIBXML}/bin/* ${BUNDLE}/bin
cp ${PREFIX_PROJ}/bin/* ${BUNDLE}/bin
cp ${PREFIX_ZLIB}/bin/* ${BUNDLE}/bin

cp ${BUILDCHAIN}/bin/libgcc*.dll ${BUNDLE}/bin
cp ${BUILDCHAIN}/bin/libstdc++*.dll ${BUNDLE}/bin
cp ${BUILDCHAIN}/bin/libwinpthread*.dll ${BUNDLE}/bin

