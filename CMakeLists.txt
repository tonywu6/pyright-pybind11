cmake_minimum_required(VERSION 3.15...3.22)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(PYTHON_EXECUTABLE .venv/bin/python3.8)

project(calculator LANGUAGES CXX)

set(pybind11_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.venv/lib/python3.8/site-packages/pybind11/share/cmake/pybind11)
find_package(pybind11 REQUIRED)

pybind11_add_module(calculator calculator.cpp)

target_include_directories(calculator PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/.venv/include/python3.8>
)
