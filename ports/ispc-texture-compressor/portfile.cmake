vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://github.com/GameTechDev/ISPCTextureCompressor/archive/master.tar.gz"
    FILENAME "ispc-texture-compressor-source.tar.gz"
    SHA512 baaa53cea4c33312ba07039ab5e65f0daa37a4bdb26dca97b17f86bd17e99fd512bb53278dd2daa29f036c8348fa9fb4fb24ca4e5821514d25a6105654329085
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

# Copy our CMake files to the source directory
file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
    "${CMAKE_CURRENT_LIST_DIR}/ispc_texcompConfig.cmake.in"
    DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ispc_texcomp PACKAGE_NAME ispc_texcomp)

vcpkg_copy_pdbs()

# Remove duplicate headers from debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
