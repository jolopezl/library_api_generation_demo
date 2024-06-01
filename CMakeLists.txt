cmake_minimum_required(VERSION 3.10)
project(LibraryBindings)

set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g")

find_package(PythonLibs REQUIRED)
find_package(TCL REQUIRED)

include_directories(${PYTHON_INCLUDE_DIRS} ${TCL_INCLUDE_PATH} ${CMAKE_SOURCE_DIR})

# Add your C++ library
add_library(library SHARED library.cpp)

# Custom command for generating Python bindings with SWIG
add_custom_command(
  OUTPUT ${CMAKE_BINARY_DIR}/library_wrap.cxx ${CMAKE_BINARY_DIR}/library.py
  COMMAND swig -python -c++ -o ${CMAKE_BINARY_DIR}/library_wrap.cxx -I${CMAKE_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/library.i
  DEPENDS ${CMAKE_SOURCE_DIR}/library.i ${CMAKE_SOURCE_DIR}/library.h
)

# Create a target for the Python module
add_library(_library MODULE ${CMAKE_BINARY_DIR}/library_wrap.cxx)
target_link_libraries(_library ${PYTHON_LIBRARIES} library)
set_target_properties(_library PROPERTIES PREFIX "")

# Custom command for generating Tcl bindings with SWIG
add_custom_command(
  OUTPUT ${CMAKE_BINARY_DIR}/library_tcl_wrap.cxx ${CMAKE_BINARY_DIR}/library.tcl
  COMMAND swig -tcl -c++ -o ${CMAKE_BINARY_DIR}/library_tcl_wrap.cxx -I${CMAKE_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/library.i
  DEPENDS ${CMAKE_SOURCE_DIR}/library.i ${CMAKE_SOURCE_DIR}/library.h
)

# Create a target for the Tcl module
add_library(liblibrary_tcl MODULE ${CMAKE_BINARY_DIR}/library_tcl_wrap.cxx)
target_link_libraries(liblibrary_tcl ${TCL_LIBRARY} library)
set_target_properties(liblibrary_tcl PROPERTIES PREFIX "")

# Define USE_TCL_STUBS for the Tcl module
target_compile_definitions(liblibrary_tcl PRIVATE USE_TCL_STUBS)

# Ensure that the generated files are part of the build process
add_custom_target(
  generate_bindings ALL
  DEPENDS ${CMAKE_BINARY_DIR}/library_wrap.cxx ${CMAKE_BINARY_DIR}/library_tcl_wrap.cxx
)

# Ensure the Python and Tcl modules depend on the custom target
add_dependencies(_library generate_bindings)
add_dependencies(liblibrary_tcl generate_bindings)
