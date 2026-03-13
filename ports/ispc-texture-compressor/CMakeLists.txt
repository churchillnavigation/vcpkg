cmake_minimum_required(VERSION 3.15)
project(ispc_texcomp VERSION 1.0 LANGUAGES CXX)

if(NOT EXISTS "${ISPC_EXECUTABLE}")
    message(FATAL_ERROR "ISPC executable not found at ${ISPC_EXECUTABLE}")
endif()

message(STATUS "Using ISPC: ${ISPC_EXECUTABLE}")

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
set(SOURCES
    ispc_texcomp/ispc_texcomp.cpp
    ispc_texcomp/ispc_texcomp_astc.cpp
)

set(HEADERS
    ispc_texcomp/ispc_texcomp.h
)

# ISPC files
set(ISPC_SOURCES
    ispc_texcomp/kernel.ispc
    ispc_texcomp/kernel_astc.ispc
)

# Compile ISPC files
foreach(ispc_file ${ISPC_SOURCES})
    get_filename_component(fname ${ispc_file} NAME_WE)
    get_filename_component(fdir ${ispc_file} DIRECTORY)

    set(ISPC_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${fdir}")
    set(ISPC_HEADER_FILE "${ISPC_OUTPUT_DIR}/${fname}_ispc.h")

    # Determine object file extension based on platform
    if(WIN32)
        set(ISPC_OBJ_EXT ".obj")
    else()
        set(ISPC_OBJ_EXT ".o")
    endif()
    set(ISPC_OBJ_FILE "${ISPC_OUTPUT_DIR}/${fname}_ispc${ISPC_OBJ_EXT}")

    # Determine architecture
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64|aarch64|ARM64")
            set(ISPC_ARCH "aarch64")
            set(ISPC_TARGETS "neon")
        else()
            set(ISPC_ARCH "x86-64")
            set(ISPC_TARGETS "sse2,sse4,avx,avx2")
        endif()
    else()
        if("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "arm|armhf")
            set(ISPC_ARCH "arm")
            set(ISPC_TARGETS "neon")
        else()
            set(ISPC_ARCH "x86")
            set(ISPC_TARGETS "sse2,sse4,avx,avx2")
        endif()
    endif()

    # Determine OS
    if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set(ISPC_OS "linux")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(ISPC_OS "ios")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        set(ISPC_OS "macos")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        set(ISPC_OS "windows")
    endif()

    # ISPC compilation command
    set(ISPC_COMPILE_ARGS "-O2" "--arch=${ISPC_ARCH}" "--target=${ISPC_TARGETS}" "--target-os=${ISPC_OS}" "--opt=fast-math")

    if(NOT WIN32)
        list(APPEND ISPC_COMPILE_ARGS "--pic")
    endif()

    # Generate object files for each target (ispc only does this if you have more than one target)
    set(ISPC_TARGET_OBJS "")
    string(REPLACE "," ";" ISPC_TARGETS_LIST "${ISPC_TARGETS}")
    list(LENGTH ISPC_TARGETS_LIST ISPC_TARGETS_LIST_LEN)
    if(ISPC_TARGETS_LIST_LEN GREATER 1)
        foreach(target ${ISPC_TARGETS_LIST})
            list(APPEND ISPC_TARGET_OBJS "${ISPC_OUTPUT_DIR}/${fname}_ispc_${target}${ISPC_OBJ_EXT}")
        endforeach()
    endif()

    add_custom_command(
        OUTPUT ${ISPC_OBJ_FILE} ${ISPC_TARGET_OBJS} ${ISPC_HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${ISPC_OUTPUT_DIR}
        COMMAND ${ISPC_EXECUTABLE} ${ISPC_COMPILE_ARGS}
                "${CMAKE_CURRENT_SOURCE_DIR}/${ispc_file}"
                -o "${ISPC_OBJ_FILE}"
                -h "${ISPC_HEADER_FILE}"
        DEPENDS ${ispc_file}
        COMMENT "Compiling ISPC file ${ispc_file}"
    )

    list(APPEND ISPC_OBJS ${ISPC_OBJ_FILE} ${ISPC_TARGET_OBJS})
    list(APPEND ISPC_HEADERS ${ISPC_HEADER_FILE})
endforeach()

# Create library
add_library(ispc_texcomp SHARED ${SOURCES} ${ISPC_OBJS})

# Set include directories
target_include_directories(ispc_texcomp
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/ispc_texcomp>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/ispc_texcomp>
        $<INSTALL_INTERFACE:include>
)

# Set output name
set_target_properties(ispc_texcomp PROPERTIES
    OUTPUT_NAME ispc_texcomp
    VERSION 1.0
    SOVERSION 1
)

# Windows-specific settings
if(WIN32)
    # Use the .def file for exports on Windows
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ispc_texcomp/ispc_texcomp.def")
        target_sources(ispc_texcomp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/ispc_texcomp/ispc_texcomp.def")
    endif()
endif()

# Installation
install(TARGETS ispc_texcomp
    EXPORT ispc_texcompTargets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES ${HEADERS} DESTINATION include/ispc_texcomp)

# Install CMake config files
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/ispc_texcompConfigVersion.cmake"
    VERSION 1.0
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/ispc_texcompConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/ispc_texcompConfig.cmake"
    INSTALL_DESTINATION lib/cmake/ispc_texcomp
)

install(EXPORT ispc_texcompTargets
    FILE ispc_texcompTargets.cmake
    NAMESPACE ispc_texcomp::
    DESTINATION lib/cmake/ispc_texcomp
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/ispc_texcompConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/ispc_texcompConfigVersion.cmake"
    DESTINATION lib/cmake/ispc_texcomp
)
