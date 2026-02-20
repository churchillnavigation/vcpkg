vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adobe/XMP-Toolkit-SDK
    REF "v2025.03"
    SHA512 b2282b53b954b3e0b173733c80f3e5580cc7ee7a0b54117516dc396d538c33837dc359385773ddd639bf70a7497e1d625de3b93b5b80ef189ff894a2dcba7763
    HEAD_REF main
    PATCHES
        use-vcpkg-dependencies.patch
)

# Set build type options
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_STATIC_OPTION "-DXMP_BUILD_STATIC=ON")
else()
    set(BUILD_STATIC_OPTION "-DXMP_BUILD_STATIC=OFF")
endif()

# Configure CMake
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/build"
    OPTIONS
        ${BUILD_STATIC_OPTION}
)

# Build (but don't use vcpkg_cmake_install as SDK has custom output structure)
vcpkg_cmake_build()

# Manually install libraries - SDK outputs to public/libraries/<platform>/<config>/
# The SDK uses custom naming: staticXMPCore.ar and staticXMPFiles.ar for static builds on Linux
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Static libraries
    if(VCPKG_TARGET_IS_LINUX)
        # Determine platform directory based on architecture
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(LIB_DIR "i80386linux_x64")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(LIB_DIR "aarch64linux")
        else()
            set(LIB_DIR "i80386linux")
        endif()
        set(XMPCORE_LIB "staticXMPCore.ar")
        set(XMPFILES_LIB "staticXMPFiles.ar")
        set(LIB_RENAME_EXT ".a")
    elseif(VCPKG_TARGET_IS_OSX)
        set(LIB_DIR "macintosh")
        set(XMPCORE_LIB "libXMPCoreStatic.a")
        set(XMPFILES_LIB "libXMPFilesStatic.a")
        set(LIB_RENAME_EXT "")  # No rename needed
    elseif(VCPKG_TARGET_IS_WINDOWS)
        set(LIB_DIR "windows")
        set(XMPCORE_LIB "XMPCoreStatic.lib")
        set(XMPFILES_LIB "XMPFilesStatic.lib")
        set(LIB_RENAME_EXT "")  # No rename needed
    endif()
else()
    # Dynamic libraries
    if(VCPKG_TARGET_IS_LINUX)
        # Determine platform directory based on architecture
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(LIB_DIR "i80386linux_x64")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(LIB_DIR "aarch64linux")
        else()
            set(LIB_DIR "i80386linux")
        endif()
        set(XMPCORE_LIB "libXMPCore.so")
        set(XMPFILES_LIB "libXMPFiles.so")
        set(LIB_RENAME_EXT "")  # No rename needed
    elseif(VCPKG_TARGET_IS_OSX)
        set(LIB_DIR "macintosh")
        set(XMPCORE_LIB "libXMPCore.dylib")
        set(XMPFILES_LIB "libXMPFiles.dylib")
        set(LIB_RENAME_EXT "")  # No rename needed
    elseif(VCPKG_TARGET_IS_WINDOWS)
        set(LIB_DIR "windows")
        set(XMPCORE_DLL "XMPCore.dll")
        set(XMPFILES_DLL "XMPFiles.dll")
        set(XMPCORE_LIB "XMPCore.lib")
        set(XMPFILES_LIB "XMPFiles.lib")
    endif()
endif()

# Install release libraries
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # Windows DLLs: install DLL to bin/ and import library to lib/
        file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/release/${XMPCORE_DLL}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/release/${XMPFILES_DLL}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/release/${XMPCORE_LIB}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/release/${XMPFILES_LIB}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    else()
        # Static libraries or non-Windows dynamic libraries
        if(LIB_RENAME_EXT)
            file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/release/${XMPCORE_LIB}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
                 RENAME "libXMPCore${LIB_RENAME_EXT}")
            file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/release/${XMPFILES_LIB}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
                 RENAME "libXMPFiles${LIB_RENAME_EXT}")
        else()
            file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/release/${XMPCORE_LIB}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
            file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/release/${XMPFILES_LIB}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        endif()
    endif()
endif()

# Install debug libraries
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # Windows DLLs: install DLL to debug/bin/ and import library to debug/lib/
        file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/debug/${XMPCORE_DLL}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/debug/${XMPFILES_DLL}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/debug/${XMPCORE_LIB}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/debug/${XMPFILES_LIB}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    else()
        # Static libraries or non-Windows dynamic libraries
        if(LIB_RENAME_EXT)
            file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/debug/${XMPCORE_LIB}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
                 RENAME "libXMPCore${LIB_RENAME_EXT}")
            file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/debug/${XMPFILES_LIB}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
                 RENAME "libXMPFiles${LIB_RENAME_EXT}")
        else()
            file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/debug/${XMPCORE_LIB}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            file(INSTALL "${SOURCE_PATH}/public/libraries/${LIB_DIR}/debug/${XMPFILES_LIB}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    endif()
endif()

# Install headers
file(INSTALL "${SOURCE_PATH}/public/include/" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     FILES_MATCHING 
     PATTERN "*.h" 
     PATTERN "*.hpp"
     PATTERN "*.incl_cpp")

# Remove empty source directories from headers
file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/include/XMPCommon/source"
    "${CURRENT_PACKAGES_DIR}/include/XMPCore/source")

# Remove duplicate headers from debug
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

# Create CMake targets file
set(LIBRARY_TYPE "STATIC")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LIBRARY_TYPE "SHARED")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/adobe-xmp-toolkit-sdk-targets.cmake" 
"# Generated CMake target import file

# Compute the installation prefix relative to this file
get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)
get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)
get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)

if(NOT TARGET adobe-xmp-toolkit-sdk::XMPCore)
    add_library(adobe-xmp-toolkit-sdk::XMPCore ${LIBRARY_TYPE} IMPORTED)
    set_target_properties(adobe-xmp-toolkit-sdk::XMPCore PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES \"\${_IMPORT_PREFIX}/include\"
    )
    
    # Link to dependencies (use expat::expat, the actual target from expat's config)
    set_property(TARGET adobe-xmp-toolkit-sdk::XMPCore APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES expat::expat
    )
    
    # Set up locations for all build configurations
    set_target_properties(adobe-xmp-toolkit-sdk::XMPCore PROPERTIES
        IMPORTED_LOCATION_DEBUG \"\${_IMPORT_PREFIX}/debug/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPCore${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
        IMPORTED_LOCATION_RELEASE \"\${_IMPORT_PREFIX}/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPCore${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
        IMPORTED_LOCATION_RELWITHDEBINFO \"\${_IMPORT_PREFIX}/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPCore${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
        IMPORTED_LOCATION_MINSIZEREL \"\${_IMPORT_PREFIX}/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPCore${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
    )
    
    # Set default IMPORTED_LOCATION (used when CMAKE_BUILD_TYPE is not set)
    set_property(TARGET adobe-xmp-toolkit-sdk::XMPCore PROPERTY
        IMPORTED_LOCATION \"\${_IMPORT_PREFIX}/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPCore${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
    )
endif()

if(NOT TARGET adobe-xmp-toolkit-sdk::XMPFiles)
    add_library(adobe-xmp-toolkit-sdk::XMPFiles ${LIBRARY_TYPE} IMPORTED)
    set_target_properties(adobe-xmp-toolkit-sdk::XMPFiles PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES \"\${_IMPORT_PREFIX}/include\"
    )
    
    # Link to dependencies
    set_property(TARGET adobe-xmp-toolkit-sdk::XMPFiles APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES ZLIB::ZLIB adobe-xmp-toolkit-sdk::XMPCore
    )
    
    # Set up locations for all build configurations
    set_target_properties(adobe-xmp-toolkit-sdk::XMPFiles PROPERTIES
        IMPORTED_LOCATION_DEBUG \"\${_IMPORT_PREFIX}/debug/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPFiles${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
        IMPORTED_LOCATION_RELEASE \"\${_IMPORT_PREFIX}/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPFiles${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
        IMPORTED_LOCATION_RELWITHDEBINFO \"\${_IMPORT_PREFIX}/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPFiles${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
        IMPORTED_LOCATION_MINSIZEREL \"\${_IMPORT_PREFIX}/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPFiles${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
    )
    
    # Set default IMPORTED_LOCATION (used when CMAKE_BUILD_TYPE is not set)
    set_property(TARGET adobe-xmp-toolkit-sdk::XMPFiles PROPERTY
        IMPORTED_LOCATION \"\${_IMPORT_PREFIX}/lib/${CMAKE_${LIBRARY_TYPE}_LIBRARY_PREFIX}XMPFiles${CMAKE_${LIBRARY_TYPE}_LIBRARY_SUFFIX}\"
    )
endif()
")

# Configure and install the CMake config file
include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/adobe-xmp-toolkit-sdkConfig.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/adobe-xmp-toolkit-sdkConfig.cmake"
    INSTALL_DESTINATION "share/${PORT}"
)

write_basic_package_version_file(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/adobe-xmp-toolkit-sdkConfigVersion.cmake"
    VERSION "2025.03.28"
    COMPATIBILITY SameMajorVersion
)

# Install usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

