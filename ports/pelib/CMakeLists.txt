cmake_minimum_required(VERSION 3.14)
project(PeLib)

# Collect all source files
file(GLOB PELIB_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/source/buffer/*.cpp
)

file(GLOB PELIB_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/source/*.h
    ${CMAKE_CURRENT_SOURCE_DIR}/source/buffer/*.h
)

# Create static library
add_library(pelib STATIC ${PELIB_SOURCES} ${PELIB_HEADERS})

# Include directories
target_include_directories(pelib
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source/buffer>
        $<INSTALL_INTERFACE:include/pelib>
)

# Set C++ standard
set_property(TARGET pelib PROPERTY CXX_STANDARD 11)
set_property(TARGET pelib PROPERTY CXX_STANDARD_REQUIRED ON)

# Installation
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(TARGETS pelib
    EXPORT pelib-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/source/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/pelib
    FILES_MATCHING PATTERN "*.h"
)

install(EXPORT pelib-targets
    FILE pelib-targets.cmake
    NAMESPACE pelib::
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pelib
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/pelib-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/pelib-config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pelib
)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/pelib-config.cmake"
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pelib
)
