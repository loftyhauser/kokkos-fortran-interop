#!/bin/tcsh
setenv CI_SEP -
setenv CI_BUILD_TYPE release
setenv CI_BUILD_SUFFIX build
setenv CI_MACHINE_ARCH x86
setenv CI_COMPILER_FAMILY gcc
setenv CI_COMPILER_VER 7.4.0
setenv CI_COMPILER_NAME $CI_COMPILER_FAMILY$CI_SEP$CI_COMPILER_VER$CI_SEP
setenv CI_CUDA_PREFIX cuda
setenv CI_CUDA_VER 10.1
setenv CI_CUDA_NAME $CI_CUDA_PREFIX$CI_SEP$CI_CUDA_VER$CI_SEP
setenv CI_KOKKOS_PREFIX kokkos
setenv CI_KOKKOS_VER 3.0.00
setenv CI_KOKKOS_BACKEND cuda
setenv CI_KOKKOS_NAME $CI_KOKKOS_PREFIX$CI_SEP$CI_KOKKOS_VER$CI_SEP$CI_KOKKOS_BACKEND$CI_SEP$CI_BUILD_TYPE
setenv CI_PATH_PREFIX /home/$USER/kt
setenv CI_INSTALL_DIR $CI_PATH_PREFIX/$CI_MACHINE_ARCH$CI_SEP$CI_COMPILER_NAME$CI_CUDA_NAME$CI_KOKKOS_NAME
setenv CI_BUILD_DIR $CI_INSTALL_DIR$CI_SEP$CI_BUILD_SUFFIX
rm -rf $CI_INSTALL_DIR
rm -rf $CI_BUILD_DIR
mkdir -p $CI_INSTALL_DIR
mkdir -p $CI_BUILD_DIR
module load cmake/3.19.2
module load cuda/10.1
module load gcc/7.4.0
cd $CI_BUILD_DIR
cmake /home/$USER/$CI_KOKKOS_PREFIX/$CI_KOKKOS_PREFIX$CI_SEP$CI_KOKKOS_VER \
    -DCMAKE_CXX_COMPILER=/home/$USER/$CI_KOKKOS_PREFIX/$CI_KOKKOS_PREFIX$CI_SEP$CI_KOKKOS_VER/bin/nvcc_wrapper \
    -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON \
    -DCMAKE_INSTALL_PREFIX=$CI_INSTALL_DIR \
    -DKokkos_ENABLE_SERIAL=ON -DKokkos_ARCH_VOLTA70=ON \
    -DKokkos_ENABLE_CUDA=ON -DKokkos_ENABLE_CUDA_LAMBDA=ON \
    -DKokkos_ENABLE_TESTS=ON
setenv CUDA_LAUNCH_BLOCKING 1
setenv CUDA_MANAGED_FORCE_DEVICE_ALLOC 1
cmake --build $CI_BUILD_DIR --parallel
cmake --install $CI_BUILD_DIR
ctest
module purge
rm -rf $CI_BUILD_DIR