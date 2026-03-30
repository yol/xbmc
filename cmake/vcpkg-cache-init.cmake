# Cache init file for vcpkg builds.
# Sets DEP_BUILDENV so autotools-based internal dependencies (e.g. fstrcmp)
# can locate libraries installed by vcpkg.
set(VCPKG_INSTALLED "/src/build/vcpkg_installed/x64-linux" CACHE PATH "")
# Point Curl_DIR at a shim CurlConfig.cmake that loads vcpkg's CURLConfig.cmake,
# so the vcpkg wrapper's _find_package(Curl CONFIG) succeeds.
# Point Curl_DIR at a shim that loads vcpkg's CURLConfig.cmake via include(),
# so the vcpkg wrapper's _find_package(Curl CONFIG) finds CurlConfig.cmake here.
set(Curl_DIR "/src/cmake/curl-redirect" CACHE PATH "")
set(DEP_BUILDENV
    "env"
    "PKG_CONFIG_PATH=${VCPKG_INSTALLED}/lib/pkgconfig"
    "CPPFLAGS=-I${VCPKG_INSTALLED}/include"
    "LDFLAGS=-L${VCPKG_INSTALLED}/lib"
    CACHE STRING "")
