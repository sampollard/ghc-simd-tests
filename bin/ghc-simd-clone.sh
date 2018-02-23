#!/bin/sh
set -e

GHC_TAG=ghc-8.2.2-release
SRC=$1; shift
DST=$1; shift
if [ -z "$DST" ]; then
	echo "example usage: ./bin/ghc-simd-clone.sh http://git.haskell.org/ghc.git ghc-simd"
	exit 2
fi
if ! [ -d "$DST" ]; then
	git clone -b $GHC_TAG --recursive $SRC $DST
fi
cd $DST

if ! [ -d libraries/vector ]; then
	cd libraries/vector
	git remote add github git@github.com:sampollard/vector.git
	git fetch github
	git checkout -b simd-0.12.0.1 github/master
	cd ../../
fi

sed -e 's/#BuildFlavour = quick-llvm/BuildFlavour = quick-llvm/' <mk/build.mk.sample >mk/build.mk

# Build ghc
#./sync-all get -b ghc-8.2.2
if [ -z "$GHC" ] || [ -z "$LLC" ] || [ -z "$OPT" ]; then
	echo "Please set the GHC, LLC, and OPT, and CC environment variables"
	echo "Note that GHC 8.2.2. expects GHC > 7.10 and LLVM == 3.9. CC should be clang version 3.9"
	exit 1
fi
LLVM_VERSION=$($LLC --version | head -n 2 | tail -n 1 | awk '{print $3}' | cut -f 1,2 -d '.')
if [ "$LLVM_VERSION" != '3.9' ]; then
	echo "Please install llvm 3.9"
	exit 1
fi
cd ..
PREFIX=$(pwd)
cd -
./boot
./configure --enable-tarballs-autodownload --prefix=$PREFIX --with-llc=$LLC --with-opt=$OPT --with-ghc=$GHC
make
make install
