cmake_minimum_required(VERSION 2.8.4)
project(gpumcs)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES
    gpu_julia.cu
    julia.c)

add_executable(gpumcs ${SOURCE_FILES})