cd /tmp

curl -O http://llvm.org/releases/3.6.2/llvm-3.6.2.src.tar.xz
curl -O http://llvm.org/releases/3.6.2/cfe-3.6.2.src.tar.xz
curl -O http://llvm.org/releases/3.6.2/clang-tools-extra-3.6.2.src.tar.xz
curl -O http://llvm.org/releases/3.6.2/compiler-rt-3.6.2.src.tar.xz
curl -O http://llvm.org/releases/3.6.2/libcxx-3.6.2.src.tar.xz
curl -O http://llvm.org/releases/3.6.2/libcxxabi-3.6.2.src.tar.xz

mkdir llvm
tar xf llvm-3.6.2.src.tar.xz -C llvm --strip-components 1

mkdir llvm/tools/clang
tar xf cfe-3.6.2.src.tar.xz -C llvm/tools/clang --strip-components 1

mkdir llvm/tools/clang/tools/extra
tar xf clang-tools-extra-3.6.2.src.tar.xz -C llvm/tools/clang/tools/extra --strip-components 1

mkdir llvm/projects/compiler-rt
tar xf compiler-rt-3.6.2.src.tar.xz -C llvm/projects/compiler-rt --strip-components 1

mkdir llvm/projects/libcxx
tar xf libcxx-3.6.2.src.tar.xz -C llvm/projects/libcxx --strip-components 1

mkdir llvm/projects/libcxxabi
tar xf libcxxabi-3.6.2.src.tar.xz -C llvm/projects/libcxxabi --strip-components 1

rm *.tar.xz

mkdir build
cd build
cmake -G"Unix Makefiles" \
      -DCLANG_INCLUDE_DOCS=OFF \
      -DCLANG_INCLUDE_TESTS=OFF \
      -DCLANG_PLUGIN_SUPPORT=OFF \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCOMPILER_RT_INCLUDE_TESTS=OFF \
      -DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
      -DLIBCXX_ENABLE_ASSERTIONS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_TARGETS_TO_BUILD=X86 \
      ../llvm

cmake --build . -- -j$(nproc)
cmake --build . --target install -- -j$(nproc)

cd ..
rm -rf build
mkdir build
cd build
export CC=clang
export CXX=clang++
cmake -G"Unix Makefiles" \
      -DCLANG_INCLUDE_DOCS=OFF \
      -DCLANG_INCLUDE_TESTS=OFF \
      -DCLANG_PLUGIN_SUPPORT=OFF \
      -DCMAKE_BUILD_TYPE=MinSizeRel \
      -DCMAKE_CXX_LINK_FLAGS="-lc++abi" \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCOMPILER_RT_INCLUDE_TESTS=OFF \
      -DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
      -DLIBCXX_ENABLE_ASSERTIONS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_TARGETS_TO_BUILD=X86 \
      -DLLVM_ENABLE_LIBCXX=ON \
      -DLLVM_ENABLE_LIBCXXABI=ON \
      -DLLVM_ENABLE_CXX1Y=ON \
      -DLIBCXX_CXX_ABI=libcxxabi \
      -DLIBCXX_LIBCXXABI_INCLUDE_PATHS="../llvm/projects/libcxxabi/include" \
      -DLIBCXX_CXX_ABI_LIBRARY_PATH="/usr/lib" \
      -DCPACK_GENERATOR=TGZ \
      ../llvm

cmake --build . -- -j$(nproc)
cmake --build . --target package -- -j$(nproc)
