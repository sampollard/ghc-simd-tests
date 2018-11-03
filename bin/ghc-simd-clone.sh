#!/bin/sh
# Downloads all the dependencies for running the benchmarks
set -e

GHC_TAG=ghc-8.4.3-release
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
#./sync-all get -b ghc-8.4.3

export GHC=ghc
export LLC=llc
export OPT=opt
export CC=clang
if [ -z "$GHC" ] || [ -z "$LLC" ] || [ -z "$OPT" ]; then
	echo "Please set the GHC, LLC, and OPT, and CC environment variables"
	echo "Note that GHC 8.4.3. expects GHC > 7.10 and LLVM == 3.9. CC should be clang version 3.9"
	exit 1
fi
LLVM_VERSION=$($LLC --version | head -n 2 | tail -n 1 | awk '{print $3}' | cut -f 1,2 -d '.')
if [ "$LLVM_VERSION" != '5.0' ]; then
	echo "Please install llvm 5.0"
	exit 1
fi
GHC_VERSION=$($GHC --version | awk '{print $NF}' | cut -f 1,2 -d '.')
if [ "$GHC_VERSION" != '8.4' ]; then
	echo "Please install ghc 8.4"
	exit 1
fi
CC_VERSION=$($CC --version | head -n 1 | awk '{print $3}' | cut -f 1,2 -d '.')
if [ "$CC_VERSION" != '5.0' ]; then
	echo "Please install clang 5.0"
	exit 1
fi

cd ..
PREFIX=$(pwd)
cd -
./boot
./configure --enable-tarballs-autodownload --prefix=$PREFIX --with-llc=$LLC --with-opt=$OPT --with-ghc=$GHC
make
make install

# Blitz
ROOT=$(pwd)
mkdir -p external && cd external
wget https://github.com/blitzpp/blitz/archive/1.0.1.tar.gz
tar -xvf 1.0.1.tar.gz
cd blitz-1.0.1
./configure --prefix=$ROOT/external
make
make install

# Eigen
cd $ROOT/external
wget http://bitbucket.org/eigen/eigen/get/3.3.5.tar.bz2
tar -xvf 3.3.5.tar.bz2
cd eigen-eigen-b3f3d4950030
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$ROOT/external ..
make install

# SALT - I can't find this package.

# Cabal sandbox to install local dependencies
GHCBIN=$ROOT/ghc-simd/inplace/bin
GHC=$GHCBIN/ghc-stage2
cd $ROOT
cabal sandbox init
cabal install -w $GHC vector
cabal install -w $GHC deepseq
cabal install -w $GHC random
