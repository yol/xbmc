# Shim: redirect find_package(Curl CONFIG) to vcpkg's CURLConfig.cmake.
# Use include() to avoid triggering the vcpkg find_package wrapper again.
# VCPKG_INSTALLED_DIR and VCPKG_TARGET_TRIPLET are set by vcpkg's toolchain.
include("${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/curl/CURLConfig.cmake")

set(Curl_FOUND ${CURL_FOUND})
set(Curl_VERSION ${CURL_VERSION_STRING})
