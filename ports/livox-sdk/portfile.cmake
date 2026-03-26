vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Livox-SDK/Livox-SDK
    REF "v${VERSION}"
    SHA512 e54818cc3b37aac9549d82987753e347c4d297a7b7c2ab75e7a2c1f38f237501d542065defa317cc056f9d1b8a8235d5b323fcd3e0465d241230f52b496ebf42
    HEAD_REF master
    PATCHES
        fix-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SAMPLE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/livox_sdk)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
