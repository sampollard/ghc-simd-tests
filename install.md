# Build Instructions:
This is assuming you want everything installed in `SIMD_ROOT`. I recommend having this somewhere isolated. For example,

	SRC_ROOT=$HOME/haskell
	SIMD_ROOT=$HOME/haskell/local

## Then build old llvm

	cd $SRC_ROOT
	# Try LLVM 3.3
	#wget http://releases.llvm.org/3.3/llvm-3.3.src.tar.gz
	#tar -xvf llvm-3.3.src.tar.gz
	#wget http://releases.llvm.org/3.3/cfe-3.3.src.tar.gz
	#tar -xvf cfe-3.3.src.tar.gz -C llvm-3.3.src/tools/
	#mv llvm-3.3.src/tools/cfe-3.3.src llvm-3.3.src/tools/clang
	#cd llvm-3.3.src

	# Try LLVM 3.2
	wget http://releases.llvm.org/3.2/llvm-3.2.src.tar.gz
	tar -xvf llvm-3.2.src.tar.gz
	wget http://releases.llvm.org/3.2/cfe-3.2.src.tar.gz
	tar -xvf cfe-3.2.src.tar.gz -C llvm-3.2.src/tools/
	mv llvm-3.2.src/tools/cfe-3.2.src llvm-3.2.src/tools/clang
	cd llvm-3.2.src
	./configure --prefix=$SIMD_ROOT
	make
	make install

## Prerequisities for old GHC
To build the older version of ghc, you need the packages `happy` and `alex`. If they're not there, you must install them
If you don't have cabal-install you can download it [here](https://www.haskell.org/cabal/download.html)
Here's the steps

	# Optional. You don't need to do this if you already have happy and alex
	export PATH=$PATH:$HOME/.cabal/bin
	cabal install happy
	cabal install alex

## Then build an old GHC
You'll use this old ghc to build ghc-simd.

	cd $SRC_ROOT
	export PATH=$PATH:$SIMD_ROOT/bin
	wget https://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.gz
	tar -xvf gmp-4.3.2.tar.gz
	cd gmp-4.3.2
	./configure --prefix=$SIMD_ROOT
	make
	make install
	export LD_LIBRARY_PATH=$SIMD_ROOT/lib:$LD_LIBRARY_PATH

	# Try ghc 7.6.2
	wget https://downloads.haskell.org/~ghc/7.6.2/ghc-7.6.2-x86_64-unknown-linux.tar.bz2
	tar -xvjf ghc-7.6.2-x86_64-unknown-linux.tar.bz2
	cd ghc-7.6.2
	./configure --prefix=$SIMD_ROOT
	make install

	# Try ghc 7.8.3
	#wget https://downloads.haskell.org/~ghc/7.8.3/ghc-7.8.3-x86_64-unknown-linux-deb7.tar.bz2
	#tar -xvjf ghc-7.8.3-x86_64-unknown-linux-deb7.tar.bz2
	#cd ghc-7.8.3
	#./configure --prefix=$SIMD_ROOT
	#make install

## Finally, build custom ghc
TODO: Try to figure out which version of cabal. 1.22 doesn't work.

	cd $SRC_ROOT
	export PATH=$SIMD_ROOT/bin:$PATH
	git clone https://github.com/sampollard/ghc-simd-tests.git
	cd ghc-simd-tests
	./bin/ghc-simd-clone.sh http://darcs.haskell.org/ghc.git ghc-simd
	cd ghc-simd
	#./sync-all -r git://git.haskell.org remote set-url
	#./sync-all pull
	./boot
	./configure --prefix=$SIMD_ROOT --with-ghc=$SIMD_ROOT/bin/ghc --with-llc=$SIMD_ROOT/bin/llc --with-opt=$SIMD_ROOT/bin/opt --with-clang=$SIMD_ROOT/bin/clang

## Current state:
Compiling with LLVM 3.2, GHC 7.6.2 to bootstrap, and the modified  `ghc-simd-clone.sh`, we get
```
utils/ghc-cabal/Main.hs:293:45:
    Not in scope: data constructor `LibComponentLocalBuildInfo'
    Perhaps you meant `ComponentLocalBuildInfo' (imported from Distribution.Simple.LocalBuildInfo)

utils/ghc-cabal/Main.hs:294:37:
    Not in scope: data constructor `LibraryName'

utils/ghc-cabal/Main.hs:294:52:
    Not in scope: data constructor `LibraryName'

utils/ghc-cabal/Main.hs:295:35:
    Not in scope: data constructor `LibraryName'

utils/ghc-cabal/Main.hs:295:52: Not in scope: `componentLibraries'

utils/ghc-cabal/Main.hs:296:25:
    `componentLibraries' is not a (visible) constructor field name
utils/ghc-cabal/ghc.mk:34: recipe for target 'utils/ghc-cabal/dist/build/tmp/ghc-cabal' failed
make[1]: *** [utils/ghc-cabal/dist/build/tmp/ghc-cabal] Error 1
Makefile:64: recipe for target 'all' failed
make: *** [all] Error 2
```
