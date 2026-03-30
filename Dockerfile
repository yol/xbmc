FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    gcc \
    g++ \
    gdc \
    nasm \
    ninja-build \
    cmake \
    # Dependencies for libraries
    autoconf autoconf-archive automake libtool libtool-bin \
    libgles2-mesa-dev libgl1-mesa-dev libglu1-mesa-dev \
    libdrm-dev \
    # Version control / download
    git \
    curl \
    wget \
    zip \
    unzip \
    tar \
    pkg-config \
    # Python (needed by Kodi build system)
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y bison flex libudev-dev libcdio-dev default-jre swig python3-venv

# Install vcpkg
#ENV VCPKG_ROOT=/opt/vcpkg
#RUN git clone https://github.com/microsoft/vcpkg.git ${VCPKG_ROOT} \
#    && ${VCPKG_ROOT}/bootstrap-vcpkg.sh -disableMetrics

#ENV PATH="${VCPKG_ROOT}:${PATH}"

WORKDIR /src
