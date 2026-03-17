vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sporst/PeLib
    REF 13382500c9f5c3323fedf3627d1614912ff5958b
    SHA512 f68aa9d9b50a20d0e50f5ff240ee262a96df9a752e56883fee18345440d896a46bb531882fcfac7f841243b70a3b08a8edba84865edff551031006721e7c0998
    HEAD_REF master
)

# Copy the generated CMakeLists.txt
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/pelib-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "pelib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.htm")
