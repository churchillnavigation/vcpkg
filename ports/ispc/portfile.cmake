set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Determine platform key
set(key NOTFOUND)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR VCPKG_TARGET_IS_IOS)
    set(key "Darwin-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_CMAKE_SYSTEM_NAME)
    set(key "${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}")
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(key "Windows-${VCPKG_TARGET_ARCHITECTURE}")
endif()

# Download LICENSE file
vcpkg_download_distfile(license
    URLS "https://raw.githubusercontent.com/ispc/ispc/v${VERSION}/LICENSE.txt"
    FILENAME "ispc-v${VERSION}-LICENSE.txt"
    SHA512 45e713404dab8d2f2993f159fa6356f21ffcb6dc0b2869d11e625893461526ee399d87ac5d4f153ce1d7b72e913082b01a04458e995cb00b72a13229d1309e83
)

set(ARCHIVE NOTFOUND)
set(ARCHIVE_EXT NOTFOUND)

# For convenient updates, use
# vcpkg install ispc --cmake-args=-DVCPKG_ISPC_UPDATE=1
if(key STREQUAL "Linux-arm64" OR VCPKG_ISPC_UPDATE)
    set(filename "ispc-v${VERSION}-linux.aarch64.tar.gz")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/ispc/ispc/releases/download/v${VERSION}/ispc-v${VERSION}-linux.aarch64.tar.gz"
        FILENAME "${filename}"
        SHA512 c704ec929e22dce5d5a941ac64f777b38877141116829da96f277afe70b725d961c6a58eaed0d5f1cbcb3fee9bb61db058e60c99f576eda35a9e7275fd57c1bf
    )
    set(ARCHIVE_EXT ".tar.gz")
endif()

if(key STREQUAL "Linux-x64" OR VCPKG_ISPC_UPDATE)
    set(filename "ispc-v${VERSION}-linux.tar.gz")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/ispc/ispc/releases/download/v${VERSION}/ispc-v${VERSION}-linux.tar.gz"
        FILENAME "${filename}"
        SHA512 0e8efa2f3c195f2e77625bccf42df89c492aecd7e442f05f2d48f695c36dc8f4f25c10c337f2ce3e8453023a685c6e98f67faa343c6132b948aa82459a527158
    )
    set(ARCHIVE_EXT ".tar.gz")
endif()

if(key STREQUAL "Darwin-arm64" OR VCPKG_ISPC_UPDATE)
    set(filename "ispc-v${VERSION}-macOS.arm64.tar.gz")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/ispc/ispc/releases/download/v${VERSION}/ispc-v${VERSION}-macOS.arm64.tar.gz"
        FILENAME "${filename}"
        SHA512 6d5fdeed71451840732f3860117f1a199488a4eb43b842cdacf352a7a4500df875ffd65ca0432f7372b8fd8f97e8c5f139dbd99b4c14affcbe3bd196e2ab4128
    )
    set(ARCHIVE_EXT ".tar.gz")
endif()

if(key STREQUAL "Darwin-x64" OR VCPKG_ISPC_UPDATE)
    set(filename "ispc-v${VERSION}-macOS.universal.tar.gz")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/ispc/ispc/releases/download/v${VERSION}/ispc-v${VERSION}-macOS.universal.tar.gz"
        FILENAME "${filename}"
        SHA512 14d28374574dcf51fea80fe73d9d7b1d73631331a71c8f3285fb9f6263e026cab4270c1fe66ade6efeeed8fcc532d7886fb02232bf68f96ad7395329017ae9ce
    )
    set(ARCHIVE_EXT ".tar.gz")
endif()

# On macOS/iOS, ISPC has signed their binaries
# vcpkg wants to be helpful and update the rpath as it moves binaries around but this
# breaks the code signature and makes the binaries useless
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()

if(key STREQUAL "Windows-x64" OR VCPKG_ISPC_UPDATE)
    set(filename "ispc-v${VERSION}-windows.zip")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/ispc/ispc/releases/download/v${VERSION}/ispc-v${VERSION}-windows.zip"
        FILENAME "${filename}"
        SHA512 e0bc4c2bff63317fd9a73727c9228f3287abe6261bf58017e9f98cc962b3ec53cdd0d7cc248fbe6a64e72911fcca7d30d10164f8545d3c0d4a91c1e1d0e6b107
    )
    set(ARCHIVE_EXT ".zip")
endif()

if(NOT ARCHIVE)
    message(FATAL_ERROR "Unsupported platform '${key}'. Please implement me!")
endif()

if(VCPKG_ISPC_UPDATE)
    message(STATUS "All downloads are up-to-date.")
    message(FATAL_ERROR "Stopping due to VCPKG_ISPC_UPDATE being enabled.")
endif()

# Extract the archive
vcpkg_extract_source_archive(
    BINDIST_PATH
    ARCHIVE "${ARCHIVE}"
)

# Check which features are enabled
if("library" IN_LIST FEATURES)
    # Install libraries
    file(GLOB libs
        "${BINDIST_PATH}/lib/*.lib"
        "${BINDIST_PATH}/lib/*.a"
        "${BINDIST_PATH}/lib/*.dylib"
        "${BINDIST_PATH}/lib/*.so"
        "${BINDIST_PATH}/lib/*.so.*"
    )
    if(libs)
        file(INSTALL ${libs} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    endif()

    # Install DLLs on Windows
    if(VCPKG_TARGET_IS_WINDOWS)
        file(GLOB dlls "${BINDIST_PATH}/bin/*.dll")
        if(dlls)
            file(INSTALL ${dlls} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()
    endif()

    # Replicate for debug (prebuilt binaries don't have separate debug builds)
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
        if(EXISTS "${CURRENT_PACKAGES_DIR}/lib")
            file(INSTALL "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
        endif()
        if(VCPKG_TARGET_IS_WINDOWS AND EXISTS "${CURRENT_PACKAGES_DIR}/bin")
            file(INSTALL "${CURRENT_PACKAGES_DIR}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
        endif()
    endif()

    # Install headers
    if(EXISTS "${BINDIST_PATH}/include")
        file(COPY "${BINDIST_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    endif()

    # Handle CMake config files
    # Move lib/cmake/* to share/
    if(EXISTS "${BINDIST_PATH}/lib/cmake")
        file(GLOB cmake_dirs "${BINDIST_PATH}/lib/cmake/*")
        foreach(cmake_dir ${cmake_dirs})
            get_filename_component(config_name "${cmake_dir}" NAME)
            file(COPY "${cmake_dir}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${config_name}")
        endforeach()
    endif()

    # Fixup CMake configs
    block(SCOPE_FOR VARIABLES)
        set(VCPKG_BUILD_TYPE Release) # no separate debug binaries

        # Fix ispc config if it exists
        if(EXISTS "${CURRENT_PACKAGES_DIR}/share/ispc")
            vcpkg_cmake_config_fixup(CONFIG_PATH share/ispc PACKAGE_NAME ispc)

            # Update the config to point to tools/ispc
            if(EXISTS "${CURRENT_PACKAGES_DIR}/share/ispc/ispcConfig.cmake")
                vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ispc/ispcConfig.cmake"
                    [[set(ISPC_EXECUTABLE "${PACKAGE_PREFIX_DIR}/bin/ispc")]]
                    [[set(ISPC_EXECUTABLE "${PACKAGE_PREFIX_DIR}/tools/ispc/ispc")]]
                )
            endif()
        endif()

        # Fix ispcrt config if it exists
        if(EXISTS "${CURRENT_PACKAGES_DIR}/share/ispcrt-${VERSION}")
            vcpkg_cmake_config_fixup(CONFIG_PATH share/ispcrt-${VERSION} PACKAGE_NAME ispcrt)
        endif()
    endblock()
endif()

if("tools" IN_LIST FEATURES)
    # Install the ispc executable to tools/ispc/
    file(GLOB ispc_exe
        "${BINDIST_PATH}/bin/ispc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "${BINDIST_PATH}/bin/ispc"
    )
    if(ispc_exe)
        file(INSTALL ${ispc_exe} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(CHMOD "${CURRENT_PACKAGES_DIR}/tools/${PORT}/ispc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        )
    endif()
endif()

# Install license
vcpkg_install_copyright(FILE_LIST "${license}")
