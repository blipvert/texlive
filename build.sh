#!/usr/bin/env bash
#
# Public Domain
#
# new script to build mpost binary
# ----------
# Options:
#       --make      : only make, no make distclean; configure
#       --parallel  : make -j 4 -l 4.0
#       --nostrip   : do not strip binary
#       --mingw     : crosscompile for mingw32 from linux
#       --mingw64   : crosscompile for mingw64 from linux
      

# try to find gnu make; we may need it
if [ -z "$MAKE" ]; then
  MAKE=make;
  if make -v 2>&1| grep "GNU Make" >/dev/null
  then 
    echo "Your make is a GNU-make; I will use that"
  elif gmake -v >/dev/null 2>&1
  then
    MAKE=gmake;
    export MAKE;
    echo "You have a GNU-make installed as gmake; I will use that"
  else
    echo "I can't find a GNU-make; I'll try to use make and hope that works." 
    echo "If it doesn't, please install GNU-make."
  fi
fi

ONLY_MAKE=FALSE
STRIP_MPOST=TRUE
MINGWCROSS=FALSE
MINGWCROSS64=FALSE
PPCCROSS=FALSE
JOBS_IF_PARALLEL=4
MAX_LOAD_IF_PARALLEL=4.0
CONFPREFIX="--prefix=/opt/texlive"

while [ "$1" != "" ] ; do
  if [ "$1" = "--make" ] ;
  then ONLY_MAKE=TRUE ;
  elif [ "$1" = "--nostrip" ] ;
  then STRIP_MPOST=FALSE ;
  elif [ "$1" = "--mingw" ] ;
  then MINGWCROSS=TRUE ;
  elif [ "$1" = "--mingw64" ] ;
  then MINGWCROSS64=TRUE ;
  elif [ "$1" = "--ppc" ] ;
  then PPCCROSS=TRUE ;
  elif [ "$1" = "--parallel" ] ;
  then MAKE="$MAKE -j $JOBS_IF_PARALLEL -l $MAX_LOAD_IF_PARALLEL" ;
  elif [ "${1%%=*}" = "--prefix" ] ;
  then CONFPREFIX="$1" ;
  fi ;
  shift ;
done

#
STRIP=strip
MPOSTEXE=mpost

if [ `uname` = "Darwin" ] ; 
then
   export MACOSX_DEPLOYMENT_TARGET=10.5
fi;

B=build
CONFHOST=

if [ "$MINGWCROSS" = "TRUE" ]
then
  B=build-windows
  STRIP=i586-mingw32msvc-strip
  MPOSTEXE=mpost.exe
  CONFHOST="--host=i586-mingw32msvc --build=i586-linux-gnu "
fi

if [ "$MINGWCROSS64" = "TRUE" ]
then
  B=build-windows64
  STRIP=x86_64-w64-mingw32-strip
  MPOSTEXE=mpost.exe
  CONFHOST="--host=x86_64-w64-mingw32 --build=x86_64-unknown-linux-gnu"
fi



if [ "$PPCCROSS" = "TRUE" ]
then
  B=ppc
  CFLAGS="-arch ppc $CFLAGS"
  XCFLAGS="-arch ppc $XCFLAGS"
  CXXFLAGS="-arch ppc $CXXFLAGS"
  LDFLAGS="-arch ppc $LDFLAGS" 
  export CFLAGS CXXFLAGS LDFLAGS XCFLAGS  
fi

case `uname` in
  MINGW32*    ) MPOSTEXE=mpost.exe ;;
  CYGWIN*    ) MPOSTEXE=mpost.exe ;;
esac

# ----------
# clean up, if needed
if [ -r "$B"/Makefile -a $ONLY_MAKE = "FALSE" ]
then
  rm -rf "$B"
elif [ ! -r "$B"/Makefile ]
then
    ONLY_MAKE=FALSE
fi
if [ ! -r "$B" ]
then
  mkdir "$B"
fi
#
cd "$B"

if [ "$ONLY_MAKE" = "FALSE" ]
then
../source/configure  $CONFHOST $CONFPREFIX \
    --disable-all-pkgs \
    --disable-native-texlive-build \
    --disable-shared    \
    --disable-largefile \
    --disable-synctex \
    --disable-mflua \
    --disable-mfluajit \
    --disable-pmp \
    --disable-upmp \
    --disable-ptex \
    --disable-eptex \
    --disable-uptex \
    --disable-euptex \
    --disable-aleph \
    --disable-xetex \
    --disable-pdftex \
    --disable-luatex \
    --disable-luajittex \
    --enable-tex \
    --enable-mf \
    --enable-mp \
    --enable-web2c \
    --enable-compiler-warnings=max \
    --with-system-mpfr \
    --with-system-gmp \
    --with-system-harfbuzz \
    --with-system-cairo \
    --with-system-libpng \
    --with-system-ptexenc \
    --with-system-kpathsea \
    --with-system-xpdf \
    --with-system-freetype2 \
    --with-system-gd \
    --with-system-teckit \
    --with-system-t1lib \
    --with-system-icu \
    --with-system-graphite2 \
    --with-system-zziplib \
    --with-system-poppler \
    --without-mf-x-toolkit \
    --without-x \
    || exit 1 
fi


##    --without-system-zlib no, poopler conflicts
$MAKE

# go back
cd ..

if [ "$STRIP_MPOST" = "TRUE" ] ;
then
  $STRIP "$B"/texk/web2c/$MPOSTEXE
else
  echo "mpost binary not stripped"
fi

# show the results
ls -l "$B"/texk/web2c/$MPOSTEXE
 
