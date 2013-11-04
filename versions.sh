
# Note that this tool chain: targets win32; includes gcc 4.8.2; uses sjlj 
# exceptions. Downloaded from: 
#http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/4.8.2/threads-posix/sjlj/
BUILDCHAIN=/c/mingw32

# CMake from:
# http://www.cmake.org/files/v2.8/cmake-2.8.12-win32-x86.zip
CMAKE_PATH=/c/cmake

# This is where we download source tar balls
SOURCES=/c/rebuilt/sources
# This is where we unpack source and build it 
BUILDS=/c/rebuilt/builds
# This is where we install our built code
RELEASES=/c/rebuilt/releases

# This gets appended to install paths to remind us our target
OS_BUILD=w32

# These are the versions we are downloading
V_AUTOCONF=2.69
V_AUTOMAKE=1.14
V_LIBTOOL=2.4.2
V_CUNIT=2.1-2
V_LIBICONV=1.13.1
V_LIBXML=2.7.8
V_JSON=0.10
V_GEOS=3.4.2
V_PROJ=4.8.0
V_GDAL=1.10.1
V_XSLT=1.1.28

V_POSTGIS_MAJOR=2.1
V_POSTGIS_PATCH=0
V_POSTGIS=${V_POSTGIS_MAJOR}.${V_POSTGIS_PATCH}

V_PGSQL_MAJOR=9.3
V_PGSQL_PATCH=1
V_PGSQL=${V_PGSQL_MAJOR}.${V_PGSQL_PATCH}

# These are the build output target paths.
# Tools get stuff into the build chain.
PREFIX_AUTOCONF=${BUILDCHAIN}
PREFIX_AUTOAKE=${BUILDCHAIN}
PREFIX_LIBTOOL=${BUILDCHAIN}
PREFIX_CUNIT=${BUILDCHAIN}

# Each dependency gets its own separate install target
# to make it easier to upgrade/rebuild them independently.
PREFIX_LIBICONV=${RELEASES}/libiconv-${V_LIBICONV}-${OS_BUILD}
PREFIX_LIBXML=${RELEASES}/libxml2-${V_LIBXML}-${OS_BUILD}
PREFIX_JSON=${RELEASES}/json-c-${V_JSON}-${OS_BUILD}
PREFIX_GEOS=${RELEASES}/geos-${V_GEOS}-${OS_BUILD}
PREFIX_PROJ=${RELEASES}/proj-${V_PROJ}-${OS_BUILD}
PREFIX_GDAL=${RELEASES}/gdal-${V_GDAL}-${OS_BUILD}
PREFIX_PGSQL=${RELEASES}/pgsql-${V_PGSQL_MAJOR}-${OS_BUILD}
PREFIX_GTK=${RELEASES}/gtk-w32
PREFIX_ZLIB=${RELEASES}/zlib-w32
PREFIX_XSLT=${RELEASES}/xslt-w32

# When finally testing, running we need all the DLLs on
# one PATH, and this makes it easier to build that kind 
# of big PATH. Also to test that we have all our 
# dependencies in place before trying to build PostGIS itself.
PREFIXES=""
PREFIXES+=" ${PREFIX_GDAL}"
PREFIXES+=" ${PREFIX_GEOS}"
PREFIXES+=" ${PREFIX_GTK}"
PREFIXES+=" ${PREFIX_JSON}"
PREFIXES+=" ${PREFIX_LIBICONV}"
PREFIXES+=" ${PREFIX_LIBXML}"
PREFIXES+=" ${PREFIX_PGSQL}"
PREFIXES+=" ${PREFIX_PROJ}"
PREFIXES+=" ${PREFIX_ZLIB}"
PREFIXES+=" ${PREFIX_XSLT}"


cleandir ()
{
	DIR=$1
	if [ -d $DIR ]; then
		rm -rf $DIR
	fi
}