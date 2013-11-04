
# Stop if something is awry
set -e

source versions.sh

if [ ! -d ${BUILDS} ]; then mkdir ${BUILDS}; fi
if [ ! -d ${SOURCES} ]; then mkdir ${SOURCES}; fi
if [ ! -d ${RELEASES} ]; then mkdir ${RELEASES}; fi

# Note we *exclude* the default MinGW path here, to avoid mistakes
# of mixing tools from MinGW64 and old school MinGW
export PATH="${BUILDCHAIN}/bin:${BUILDCHAIN}/lib:/bin:/sbin"

#################################################################################
# COMPILATION TOOL DEPENDENCIES
#################################################################################

if false; then
	cd ${BUILDS}
	wget -O ${SOURCES}/autoconf-${V_AUTOCONF}.tar.gz ftp://ftp.gnu.org/gnu/autoconf/autoconf-${V_AUTOCONF}.tar.gz
	tar -xvf ${SOURCES}/autoconf-${V_AUTOCONF}.tar.gz
	cd autoconf-2.69
	./configure --prefix=${PREFIX_AUTOCONF} 
	make && make install
	autoconf --version
fi

if false; then
	cd ${BUILDS}
	wget -O ${SOURCES}/automake-${V_AUTOMAKE}.tar.gz ftp://ftp.gnu.org/gnu/automake/automake-${V_AUTOMAKE}.tar.gz
	tar -xvf ${SOURCES}/automake-${V_AUTOMAKE}.tar.gz
	cd automake-${V_AUTOMAKE}
	./configure --prefix=${PREFIX_AUTOMAKE} 
	make && make install
	automake --version
fi

if false; then
	cd ${BUILDS}
	wget --no-parent -O ${SOURCES}/libtool-${V_LIBTOOL}.tar.gz  ftp://ftp.gnu.org/gnu/libtool/libtool-${V_LIBTOOL}.tar.gz
	tar -xvf ${SOURCES}/libtool-${V_LIBTOOL}.tar.gz
	cd libtool-${V_LIBTOOL}
	./configure --prefix=${PREFIX_LIBTOOL} 
	make && make install
	libtool --version
fi

if false; then
	cd ${BUILDS}
	cleandir CUnit-${V_CUNIT}
	wget --no-parent -O ${SOURCES}/CUnit-${V_CUNIT}-src.tar.bz2 http://iweb.dl.sourceforge.net/project/cunit/CUnit/${V_CUNIT}/CUnit-${V_CUNIT}-src.tar.bz2
	tar xvf ${SOURCES}/CUnit-${V_CUNIT}-src.tar.bz2
	cd CUnit-${V_CUNIT}
	./configure --prefix=${PREFIX_CUNIT}
	make clean
	make && make install
	make check
	#rm -rf ${BUILDS}/CUnit-${V_CUNIT}
fi


#################################################################################
# RUN-TIME LIBRARY DEPENDENCIES
#################################################################################

if false; then

	GTK_FILE=gtk+-bundle_2.24.10-20120208_win32.zip
	if [ ! -f ${SOURCES}/${GTK_FILE} ]; then
		wget -O ${SOURCES}/${GTK_FILE} http://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/2.24/${GTK_FILE}
	fi
	cleandir ${PREFIX_GTK}
	mkdir ${PREFIX_GTK}
	unzip -d ${PREFIX_GTK} ${SOURCES}/${GTK_FILE}
	
fi

if false; then

	cd ${SOURCES}
	wget http://downloads.sourceforge.net/project/gnuwin32/zlib/1.2.3/zlib-1.2.3-lib.zip
	wget http://downloads.sourceforge.net/project/gnuwin32/zlib/1.2.3/zlib-1.2.3-bin.zip

	cleandir ${PREFIX_ZLIB}
	mkdir ${PREFIX_ZLIB}
	
	unzip -d ${PREFIX_ZLIB} zlib-1.2.3-bin.zip
	unzip -d ${PREFIX_ZLIB} zlib-1.2.3-lib.zip
		
fi

if false; then
	cd ${BUILDS}
	wget --no-parent -O ${SOURCES}/libiconv-${V_LIBICONV}.tar.gz http://ftp.gnu.org/gnu/libiconv/libiconv-${V_LIBICONV}.tar.gz
	cleandir libiconv-${V_LIBICONV}
	cleandir ${PREFIX_LIBICONV}
	tar xvfz ${SOURCES}/libiconv-${V_LIBICONV}.tar.gz
	cd libiconv-${V_LIBICONV}
	export LDFLAGS="-static-libgcc"
	./configure --prefix=${PREFIX_LIBICONV} 
	make && make install
	make check
	#rm -rf ${BUILDS}/libiconv-${V_LIBICONV}
fi 

if false; then

	LIBXML_NAME=libxml2-${V_LIBXML}
	LIBXML_FILE=${LIBXML_NAME}.tar.gz
	
	cd ${BUILDS}
	if [ ! -f ${SOURCES}/${LIBXML_FILE} ]; then
		wget -O ${SOURCES}/${LIBXML_FILE} ftp://xmlsoft.org/libxml2/${LIBXML_FILE}
	fi
	cleandir ${LIBXML_NAME}
	cleandir ${PREFIX_LIBXML}
	tar xvfz ${SOURCES}/${LIBXML_FILE} 
	cd ${LIBXML_NAME}

	./configure \
	--prefix=${PREFIX_LIBXML} \
	--with-iconv=${PREFIX_LIBICONV} \
	--with-zlib=${PREFIX_ZLIB} \
	--with-threads=no 
	echo $PATH > buildpath.txt
	make && make install
	#make check
fi

if false; then

	XSLT_FILE=libxslt-1.1.26.win32.zip
	XML_FILE=libxml2-2.7.8.win32.zip
	ICONV_FILE=iconv-1.9.2.win32.zip
	
	cd ${SOURCES}
	if [ ! -f ${SOURCES}/${ICONV_FILE} ]; then
		wget ftp://ftp.zlatkovic.com/libxml/${XSLT_FILE}
		wget ftp://ftp.zlatkovic.com/libxml/${XML_FILE}
		wget ftp://ftp.zlatkovic.com/libxml/${ICONV_FILE}
	fi

	cleandir ${PREFIX_XSLT}
	mkdir -p ${PREFIX_XSLT}
	cd ${PREFIX_XSLT}
	unzip ${SOURCES}/${XML_FILE}
	cd libxml2-2.7.8.win32
	cp -r bin ..
	cd ..
	unzip ${SOURCES}/${XSLT_FILE}
	cd libxslt-1.1.26.win32
	cp -r bin ..
	cd ..
	unzip ${SOURCES}/${ICONV_FILE}
	cd iconv-1.9.2.win32
	cp -r bin ..
	cd ..
		
fi

if false; then
	JSON_NAME=json-c-${V_JSON}
	JSON_FILE=${JSON_NAME}.zip

	cd ${SOURCES}
	if [ -f ${JSON_FILE} ]; then rm -f ${JSON_FILE}; fi
	wget  --no-check-certificate --output-document=${JSON_FILE} https://github.com/json-c/json-c/archive/${JSON_FILE}

	cd ${BUILDS}
	cleandir ${JSON_NAME}
	cleandir ${PREFIX_JSON}
	unzip ${SOURCES}/${JSON_FILE} 
	mv json-c-json-c-${V_JSON} ${JSON_NAME}
	cd ${JSON_NAME}
	## had to compile with -w (disable warnings otherwise it gave errors)
	# note we use --enable-static -disable-shared so we don't have a small itsy bitsy json..dll we need to distribute
	# this will force json support to be embedded directly in postgis-.dll
	./configure \
	--prefix=${PREFIX_JSON} \
	--enable-static \
	--disable-shared CFLAGS=-w
	make && make install
	#for some reason install fails to copy this file
	cp json_object_iterator.h ${PREFIX_JSON}/include/json/json_object_iterator.h
fi


# Regina builds GEOS with CMake, but CMake doesn't create a
# usable geos-config, which introduces problems later. The 
# autotools build works, so we stick with that for now.
if false; then

	GEOS_NAME=geos-${V_GEOS}
	GEOS_FILE=${GEOS_NAME}.tar.bz2

	cd ${BUILDS}	
	cleandir ${GEOS_NAME}
	cleandir ${PREFIX_GEOS}
	wget -O ${SOURCES}/${GEOS_FILE} http://download.osgeo.org/geos/${GEOS_FILE}
	tar xvfj ${SOURCES}/${GEOS_FILE}
	
	cd ${GEOS_NAME}
	./configure --prefix=${PREFIX_GEOS}

	make && make install
	cd ${PREFIX_GEOS}/bin
	strip *.dll
fi

if false; then

	PG_NAME=postgresql-${V_PGSQL}
	PG_DIR=${BUILDS}/${PG_NAME}
	PG_FILE=${PG_NAME}.tar.bz2
	
	cd ${BUILDS}

	cleandir ${PG_NAME}
	cleandir ${PREFIX_PGSQL}
	
	if [ ! -f ${SOURCES}/${PG_FILE} ]; then
		wget -O ${SOURCES}/${PG_FILE} http://ftp.postgresql.org/pub/source/v${V_PGSQL}/${PG_FILE}
	fi
	tar -xvjf ${SOURCES}/${PG_FILE}
	cd ${PG_NAME}

	LD_LIBRARY_PATH=${PREFIX_PGSQL}/lib \
	./configure \
	--prefix=${PREFIX_PGSQL} \
	--with-pgport=5432 \
	--disable-float8-byval \
	--enable-cassert \
	--enable-debug \
	--with-includes="${PREFIX_LIBICONV}/include ${PREFIX_LIBXML}/include ${PREFIX_ZLIB}/include" \
	--with-libraries="${PREFIX_LIBICONV}/bin ${PREFIX_LIBXML}/bin ${PREFIX_ZLIB}/bin" \
	--enable-integer-datetimes 
	make && make install
	
	cp ${PREFIX_PGSQL}/lib/libpq.dll ${PREFIX_PGSQL}/bin
	
	for CTRB in btree_gist seg cube file_fdw intarray ltree postgres_fdw adminpack hstore fuzzystrmatch pg_trgm
	do
		cd ${PG_DIR}/contrib/${CTRB}
		make && make install
	done

fi

if false; then

	PROJ_NAME=proj-${V_PROJ}
	PROJ_DATUM=proj-datumgrid-1.5.zip

	cd ${BUILDS}
	
	cleandir ${PROJ_NAME}
	cleandir ${PREFIX_PROJ}
	
	wget -O ${SOURCES}/${PROJ_NAME}.tar.gz http://download.osgeo.org/proj/${PROJ_NAME}.tar.gz
	wget -O ${SOURCES}/${PROJ_DATUM} http://download.osgeo.org/proj/${PROJ_DATUM} 
	tar xvzf ${SOURCES}/${PROJ_NAME}.tar.gz || /bin/true
	cd ${PROJ_NAME}/nad
	unzip ${SOURCES}/${PROJ_DATUM}
	cd ..
	./configure --prefix=${PREFIX_PROJ}
	make clean && make && make install
	cd ${PREFIX_PROJ}/bin
	strip *.dll
fi

if false; then

	GDAL_NAME=gdal-${V_GDAL}

	cd ${BUILDS}
	cleandir ${GDAL_NAME}
	cleandir ${PREFIX_GDAL}
	if [ ! -f ${SOURCES}/${GDAL_NAME}.tar.gz ]; then
		wget -O ${SOURCES}/${GDAL_NAME}.tar.gz http://download.osgeo.org/gdal/${V_GDAL}/${GDAL_NAME}.tar.gz 
	fi
	tar xvfz ${SOURCES}/${GDAL_NAME}.tar.gz
	cd ${GDAL_NAME}

	./configure \
	--with-curl=no \
	--with-threads=no \
	--enable-shared \
	--with-geos=no \
	--with-pg=${PREFIX_PGSQL}/bin/pg_config \
    --with-libz=internal \
	--with-libiconv-prefix=${PREFIX_LIBICONV} \
	--with-xml2=${PREFIX_LIBXML}/bin/xml2-config \
	--prefix=${PREFIX_GDAL}
	make && make install
#	cd ${PREFIX_GDAL}/bin
#	strip *.dll

fi


exit

