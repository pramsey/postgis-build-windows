postgis-build-windows
=====================

These scripts start from a minimal MSYS install and MinGW64 build chain, and download and compile the required dependencies to build PostGIS under Windows.

The chain presented here has built and tested under Windows 7 professional, fully patched as of November 1, 2013.


Clean VM
--------

Start with a clean Windows 7 VM. The presence of other installed libraries from other software may interfere with this build, who knows, it's a finicky proposition all around.


Utilities
---------

Install the native versions of some core utilities:

- http://git-scm.com/download/win
- http://www.cmake.org/cmake/resources/software.html


MSYS
----

MSYS provides the UNIX-style BASH shell and command-line utilities necessary for the build to succeed.

- Download and run MinGW current installer from http://sourceforge.net/projects/mingw/files/
  * Select and install **only** `msys-base`
- Open the MSYS BASH commandline
- Add the base MinGW path to yours so you can access `mingw-get`
  * `export PATH=$PATH:/c/mingw/bin`
- Install extra MSYS utilities that help with the build process
  * `mingw-get install msys-wget`
  * `mingw-get install msys-perl`
  * `mingw-get install unzip`


MinGW64
-------

MinGW64 seems like a weird project. There's a lot of different options out there. Basically, MSYS provides the shell and tools, and MinGW64 provides the compiler. And there's lots of choices available of what compiler to use.

The basic principle of operation is, that if you set up your `PATH` correctly (controlled by the `BUILDCHAIN` variable in the `versions.sh` file), you can make use of any MinGW64 version you wish. This makes it "easy" to test the effect of new/different builds, relatively speaking.

It's possible in theory to get MinGW64 to cross-compile, but the builds tend to expect you to choose a host architecture on install/download time, so the easiest thing to do is select an i686 compiler download, and then just let it build in native mode.

MinGW64 allows you to choose what kind of exception handling system to use, generally "Dwarf" or "SJLJ" (aka "longjmp"). Go with the "SJLJ" as a general rule, since it is older and more likely to be supported by libraries you use. There is a small performance penalty, but only for code that throws a lot of exceptions, which the PostGIS stack does not.

- The `MinGW Builds <http://sourceforge.net/projects/mingwbuilds>`_ project is the slickest build effort, bundling up the latest MinGW64 releases into an installer. Probably worth testing from time-to-time.

- The `SeZero peronsonal builds <http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/sezero_4.5_20111101/>`_ are popular in web blogs about how to build, and used by Regina Obe in her current Windows build chain. I could not get a good build out of them.

- **USE THIS ONE** The `latest mingw-builds raw build <http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/4.8.2/threads-posix/sjlj/>`_ includes GCC 4.8.2 and did give a clean build.

Unzip or unpack your build tool, and update the `BUILDCHAIN` variable to point to the root of the install directory.


versions.sh
-----------

A central script for controlling the build and bundle process. Edit as follows:

- Set up the `BUILDCHAIN` as above
- Set the storage directory locations
  - `SOURCES` where the tarballs are downloaded
  - `BUILDS` where sources are unpacked and built
  - `RELEASES` where binaries are installed
- The `V_*` variables control which version is downloaded and built. In general, these are all the latest versions.
- Based on the `PREFIX_*` variables, each package is installed into a separate release directory, to allow multiple versions to coexist easily, and incremental upgrades/changes to be applied


build_postgis_deps.sh
---------------------

The script for building out each dependency. First the build tools.

- `autoconf`
- `automake`
- `libtool`
- `cunit`

Build tools are dumped into the build chain for easy access and finding. Generally these will only be built once then left alone.

Then the binary dependencies. They are win32 builds, suitable for this build, but not suitable for a win64 build, so any future effort along those lines must find replacements.

- `gtk` Way too big and complex to build from scratch.
- `zlib` Not strictly needed if you are using the EDB PostgreSQL build, but needed for a zlib-enabled PostgreSQL build later on.
- `libxslt` XSLT is only used for building out the docs, and really only needed because the SQL comments file is generated from the docbook sources files. You can't run the regression tests without a docs built either. 

Then the source dependencies.

- `libiconv`
- `libxml2`
- `json-c`
- `geos`
- `postgresql`
- `proj`
- `gdal` Building GDAL after PostgreSQL lets us add PgSQL support to GDAL. Similar with LibXML2. We don't add GEOS support, since then GEOS updates require GDAL updates, and because we fear library conflicts. There are extra GDAL build instructions that note GDAL EXE files are statically linked and very fat, no effort has been made in this build to rectify this.


build_postgis.sh
----------------

To ensure that all the DLLs are found at link time, we add all the release directories to the `PATH` before building.

The `pg_config` utility built from PostgreSQL insists on returning Windows-style paths, which confuse the UNIX-pathed linker (it seems) so adding the PgSQL library path to the `LDFLAGS` is required, even though the path is (theoretically) already supplied by `pg_config`.

This build keeps Regina Obe's `--without-gettext` directive, which effectively removes internationalization. In future this should be added back in so translations of the GUI are possible.


bundle_postgis.sh
----------------

This script just copies the required DLL files out of the various release directories into a single target directory. It should also pick out the required GTK libraries and build a client tools directory too. For now, it serves to make testable ZIP packages.

Note that in addition to the dependency DLLs, some runtime libraries from the build chain are also copied in: libgcc, libstdc++, libwinpthread.
