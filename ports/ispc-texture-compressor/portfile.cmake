vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GameTechDev/ISPCTextureCompressor
    REF 79ddbc90334fc31edd438e68ccb0fe99b4e15aab
    SHA512 9e129a30c05c9d418aa0578aee53dcc26203383bd4bd7c3ab907e974575053020020110f4cf7c950d60b479419c3516dc4f67ff7bb0246a662cc9d095a53ad28
    HEAD_REF master
)

# Copy our CMake files to the source directory
file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
    "${CMAKE_CURRENT_LIST_DIR}/ispc_texcompConfig.cmake.in"
    DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -D_VCPKG_INSTALLED_DIR=${_VCPKG_INSTALLED_DIR}
        -DVCPKG_HOST_TRIPLET=${VCPKG_HOST_TRIPLET}
        -DVCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ispc_texcomp PACKAGE_NAME ispc_texcomp)

vcpkg_copy_pdbs()

# Remove duplicate headers from debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
