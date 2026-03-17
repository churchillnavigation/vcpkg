vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO inertialsense/inertial-sense-sdk
    REF 8a775686be8b2a5840f9c912e78287f548eb43bb
    SHA512 d3938e846516dbce8977cc64accb1640ac4fcecbd77e71ece336068d02635bd4223782d006022044b9bbf131bde78352490fc146d5d394773ca700baac2edada
    HEAD_REF master
)

# Replace the upstream CMakeLists.txt with our custom one that excludes libusb/udev
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        examples BUILD_EXAMPLES
        tests    BUILD_TESTS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "InertialSenseSDK")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
