cmake_minimum_required(VERSION 3.16.3)

project(InertialSenseSDK LANGUAGES C CXX)

include(GNUInstallDirs)

# Options for building examples and tests
option(BUILD_EXAMPLES "Build example projects" OFF)
option(BUILD_TESTS "Build tests" OFF)

# Define LINUX variable for use in this file
if(UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif()

# Collect SDK source files (excluding libusb)
file(GLOB SOURCES_SDK
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/protocol/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/util/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/hw-libs/bootloader/bootloaderShared.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/runtime/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/yaml-cpp/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/yaml-cpp/contrib/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/yaml-cpp/node/*.cpp"
)

# Exclude specific bootloader files and files that depend on libusb/udev/ISDevice/ISLogger
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISBootloader.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISDFUFirmwareUpdater.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISFirmwareUpdater.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISBFirmwareUpdater.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISDevice.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "InertialSense\\..*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISLogger.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "DeviceLog.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "DeviceManager.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "DeviceFactory.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "DataCSV.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "DataJSON.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "DataKML.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISDataMappings.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISDisplay.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "ISSerialPort.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "CorrectionService.*")
list(FILTER SOURCES_SDK EXCLUDE REGEX "Rtcm3CorrectionServer.*")

# Create the static library
add_library(${PROJECT_NAME} STATIC ${SOURCES_SDK})

# Define version macros since we don't generate repositoryInfo.h
target_compile_definitions(${PROJECT_NAME} PRIVATE
    IS_SDK_REPO_VERSION_MAJOR=2
    IS_SDK_REPO_VERSION_MINOR=7
    IS_SDK_REPO_VERSION_REVIS=0
    IS_SDK_REPO_VERSION_PRERELEASE=0
)

# Build using C11 and CXX17 for all platforms
set_property(TARGET ${PROJECT_NAME} PROPERTY C_STANDARD 11)
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)

# Include paths
target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/util>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/protocol>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/yaml-cpp>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/tests/runtime>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/external>
    $<INSTALL_INTERFACE:include/InertialSenseSDK>
)

# Platform-specific settings
if(WIN32)
    # yamlcpp needs to know it's a static lib
    target_compile_definitions(${PROJECT_NAME} PRIVATE YAML_CPP_STATIC_DEFINE)

    # We need to ensure windows static libs are found
    target_link_libraries(${PROJECT_NAME} PUBLIC Ws2_32.lib Iphlpapi.lib)

    # Windows compiler flags
    if(MSVC)
        SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /Wall")
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Wall")
    endif()
elseif(APPLE)
    # macOS compiler flags
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers -Wno-deprecated-declarations")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers -Wno-deprecated-declarations")

    # Set macOS compiler linker flag
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")

    # Link in macOS specific packages
    target_link_libraries(${PROJECT_NAME} PUBLIC "$<LINK_LIBRARY:FRAMEWORK,Foundation>" "$<LINK_LIBRARY:FRAMEWORK,IOKit>" "$<LINK_LIBRARY:FRAMEWORK,Security>")
elseif(LINUX)
    # Linux compiler flags
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers")

    # Set Linux compiler linker flag
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")

    # Link in Linux specific packages
    target_link_libraries(${PROJECT_NAME} PUBLIC m)
endif()

# Installation
install(TARGETS ${PROJECT_NAME}
    EXPORT InertialSenseSDK-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Install headers
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/InertialSenseSDK
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "libusb" EXCLUDE
    PATTERN "ISBootloader*.h" EXCLUDE
    PATTERN "ISDFUFirmwareUpdater.h" EXCLUDE
    PATTERN "ISFirmwareUpdater.h" EXCLUDE
    PATTERN "ISBFirmwareUpdater.h" EXCLUDE
    PATTERN "ISDevice.h" EXCLUDE
    PATTERN "InertialSense.h" EXCLUDE
    PATTERN "ISLogger.h" EXCLUDE
    PATTERN "DeviceLog*.h" EXCLUDE
    PATTERN "DeviceManager.h" EXCLUDE
    PATTERN "DeviceFactory.h" EXCLUDE
    PATTERN "DataCSV.h" EXCLUDE
    PATTERN "DataJSON.h" EXCLUDE
    PATTERN "DataKML.h" EXCLUDE
    PATTERN "ISDataMappings.h" EXCLUDE
    PATTERN "ISDisplay.h" EXCLUDE
    PATTERN "ISSerialPort.h" EXCLUDE
    PATTERN "CorrectionService.h" EXCLUDE
    PATTERN "Rtcm3CorrectionServer.h" EXCLUDE
)

# Install external headers
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/external/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/InertialSenseSDK/external
    FILES_MATCHING
    PATTERN "*.h"
)

# Install export targets
install(EXPORT InertialSenseSDK-targets
    FILE InertialSenseSDK-targets.cmake
    NAMESPACE InertialSenseSDK::
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/InertialSenseSDK
)

# Generate the config file
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/InertialSenseSDK-config.cmake"
    "include(CMakeFindDependencyMacro)\n"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/InertialSenseSDK-targets.cmake\")\n"
    "check_required_components(InertialSenseSDK)\n"
)

# Install the generated config file
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/InertialSenseSDK-config.cmake"
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/InertialSenseSDK
)

# Build examples if enabled
if(BUILD_EXAMPLES)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ExampleProjects")
        add_subdirectory(ExampleProjects)
    endif()
endif()

# Build tests if enabled
if(BUILD_TESTS)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests")
        add_subdirectory(tests)
    endif()
endif()
