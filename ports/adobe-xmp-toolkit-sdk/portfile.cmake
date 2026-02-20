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

