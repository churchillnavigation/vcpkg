vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adobe/XMP-Toolkit-SDK
    REF v2025.03
    SHA512 b2282b53b954b3e0b173733c80f3e5580cc7ee7a0b54117516dc396d538c33837dc359385773ddd639bf70a7497e1d625de3b93b5b80ef189ff894a2dcba7763
    PATCHES
        patches/use-vcpkg-deps.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" XMP_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/build"
    OPTIONS
        "-DXMP_BUILD_STATIC=${XMP_BUILD_STATIC}"
)

vcpkg_cmake_build()

set(LIB_ROOT "${SOURCE_PATH}/public/libraries")
file(GLOB PLATFORM_DIRS "${LIB_ROOT}/*")

foreach(_plat IN LISTS PLATFORM_DIRS)
    foreach(_cfg IN ITEMS Debug debug Release release)
        set(_dir "${_plat}/${_cfg}")
        if(EXISTS "${_dir}")
            string(TOLOWER "${_cfg}" _cfg_lc)
            if(_cfg_lc STREQUAL "debug")
                set(_dest_root "${CURRENT_PACKAGES_DIR}/debug")
            else()
                set(_dest_root "${CURRENT_PACKAGES_DIR}")
            endif()

            file(GLOB_RECURSE _bins "${_dir}/*.dll" "${_dir}/*.so" "${_dir}/*.dylib")
            foreach(_bin IN LISTS _bins)
                file(MAKE_DIRECTORY "${_dest_root}/bin")
                file(INSTALL "${_bin}" DESTINATION "${_dest_root}/bin")
            endforeach()
            file(GLOB_RECURSE _libs "${_dir}/*.lib" "${_dir}/*.a")
            foreach(_lib IN LISTS _libs)
                file(MAKE_DIRECTORY "${_dest_root}/lib")
                file(INSTALL "${_lib}" DESTINATION "${_dest_root}/lib")
            endforeach()
            file(GLOB_RECURSE _ars "${_dir}/*.ar")
            foreach(_ar IN LISTS _ars)
                get_filename_component(_ar_name "${_ar}" NAME_WE)
                file(MAKE_DIRECTORY "${_dest_root}/lib")
                file(INSTALL "${_ar}" DESTINATION "${_dest_root}/lib" RENAME "lib${_ar_name}.a")
            endforeach()
        endif()
    endforeach()
endforeach()

# headers
file(INSTALL "${SOURCE_PATH}/public/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# CMake config
set(_share_dir "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(MAKE_DIRECTORY "${_share_dir}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/${PORT}Targets.cmake.in" "${_share_dir}/${PORT}Targets.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake.in" "${_share_dir}/${PORT}Config.cmake" @ONLY)

# usage
file(WRITE "${_share_dir}/usage" "Basic usage (static libs only):\n")
file(APPEND "${_share_dir}/usage" "  find_package(adobe-xmp-toolkit-sdk CONFIG REQUIRED)\n")
file(APPEND "${_share_dir}/usage" "  target_link_libraries(main PRIVATE adobe::XMPFiles adobe::XMPCore)\n\n")
file(APPEND "${_share_dir}/usage" "Headers live in <XMP*>. You must define TXMP_STRING_TYPE (e.g. std::string)\n")
file(APPEND "${_share_dir}/usage" "in your translation unit and include XMP.incl_cpp exactly once to instantiate\n")
file(APPEND "${_share_dir}/usage" "templates. See SDK docs for details.\n")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
