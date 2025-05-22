#!/bin/bash
export CC=mpicc
export CXX=mpicxx

ROOT=$HOME/opt/chroma_docker
SRC=${ROOT}
BIN=${ROOT}/build
DST=${ROOT}/install
# echo $BIN

# 0: Nothing; 1: Build and install; 2: Configure, build and install.
BUILD_QDPXX=2
BUILD_QUDA=0
BUILD_CHROMA=2

if [ ${BUILD_QDPXX} -gt 0 ]; then
    mkdir -p ${BIN}/qmp
    pushd ${BIN}/qmp
    if [ ${BUILD_QDPXX} -gt 1 ]; then
        rm -rf CMakeCache.txt
        cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release \
            -DQMP_MPI=ON \
            -DCMAKE_INSTALL_PREFIX=${DST} ${SRC}/qmp
    fi
    cmake --build . -j
    cmake --install .
    popd

    mkdir -p ${BIN}/qdpxx
    pushd ${BIN}/qdpxx
    if [ ${BUILD_QDPXX} -gt 1 ]; then
        rm -rf CMakeCache.txt
        cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX=${DST} ${SRC}/qdpxx
    fi
    cmake --build . -j
    cmake --install .
    popd
fi

if [ ${BUILD_QUDA} -gt 0 ]; then
    mkdir -p ${BIN}/quda
    pushd ${BIN}/quda
    if [ ${BUILD_QUDA} -gt 1 ]; then
        mkdir -p ${BIN}/quda/cmake
        cp ${SRC}/CPM_0.38.2.cmake ${BIN}/quda/cmake
        mkdir -p ${BIN}/quda/_deps/eigen-subbuild/eigen-populate-prefix/src
        cp ${SRC}/eigen-3.4.0.tar.bz2 ${BIN}/quda/_deps/eigen-subbuild/eigen-populate-prefix/src
        rm -rf CMakeCache.txt
        cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=DEVEL \
            -DQUDA_TARGET_TYPE=HIP -DAMDGPU_TARGETS=gfx906 -DGPU_TARGETS=gfx906 -DQUDA_GPU_ARCH=gfx906 \
            -DQUDA_QMP=ON -DQUDA_QDPJIT=ON -DQUDA_INTERFACE_QDPJIT=ON -DQUDA_BUILD_ALL_TESTS=OFF \
            -DQUDA_CLOVER_DYNAMIC=OFF -DQUDA_CLOVER_RECONSTRUCT=OFF -DQUDA_DIRAC_DOMAIN_WALL=OFF \
            -DQUDA_INTERFACE_MILC=OFF -DQUDA_LAPLACE=ON -DQUDA_MULTIGRID=ON \
            -DCMAKE_INSTALL_PREFIX=${DST} ${SRC}/quda
    fi
    cmake --build . -j32
    cmake --install .
    popd
fi

if [ ${BUILD_CHROMA} -gt 0 ]; then
    mkdir -p ${BIN}/chroma
    pushd ${BIN}/chroma
    if [ ${BUILD_CHROMA} -gt 1 ]; then
        rm -rf CMakeCache.txt
        cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Release \
            -DChroma_ENABLE_OPENMP=ON -DChroma_ENABLE_MGPROTO=OFF -DChroma_ENABLE_QPHIX=OFF -DChroma_ENABLE_JIT_CLOVER=OFF -DChroma_ENABLE_QUDA=OFF \
            -DBUILD_QOP_MG=OFF\
            -DCMAKE_INSTALL_PREFIX=${DST} ${SRC}/chroma
    fi
    cmake --build . -j 10
    cmake --install .
    popd
fi

