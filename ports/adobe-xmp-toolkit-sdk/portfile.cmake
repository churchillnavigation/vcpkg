vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adobe/XMP-Toolkit-SDK
    REF "v${VERSION}"
    SHA512 c289e116901064fe32a6a997a375b07520bc878e51786b0c80e6b1f2ae17fee2c33464207b815a32bd8aca469d20b7f995c1c86389759f1560bd01a2a55299d7
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

# Build and install
vcpkg_cmake_install()

# Install headers
file(INSTALL "${SOURCE_PATH}/public/include/" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     FILES_MATCHING 
     PATTERN "*.h" 
     PATTERN "*.hpp"
     PATTERN "*.incl_cpp")

# Remove duplicate headers from debug
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

