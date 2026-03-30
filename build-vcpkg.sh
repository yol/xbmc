#!/bin/bash
set -ex
podman build . -t vcpkgbuild
podman run --rm -it \
    --name vcpkgbuild \
    -v "$(pwd):/src:z" \
    -v "${HOME}/.cache/vcpkg:/root/.cache/vcpkg:z" \
    localhost/vcpkgbuild \
    bash -c "
      cmake -S /src -B /src/build \
        -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE=/src/vcpkg/scripts/buildsystems/vcpkg.cmake \
        -DAPP_RENDER_SYSTEM=gl \
        -DENABLE_INTERNAL_FFMPEG=OFF \
        -DENABLE_INTERNAL_FSTRCMP=ON \
        -C /src/cmake/vcpkg-cache-init.cmake \
	-DCORE_PLATFORM_NAME=x11 \
      && cmake --build /src/build
    "
