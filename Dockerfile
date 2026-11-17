# syntax=docker/dockerfile:1
FROM ghcr.io/pkgforge-dev/archlinux AS build-stage

# Prepare build dependencies
RUN pacman -Syu --noconfirm make gcc git hidapi

# Prepare AppImage Build dependencies
ARG ANYLINUX_URL=https://github.com/pkgforge-dev/Anylinux-AppImages/raw/refs/heads/main/useful-tools
RUN <<EOR
  set -eu
  pacman -Syu --noconfirm patchelf xorg-server-xvfb
  curl -fsSL "${ANYLINUX_URL}/quick-sharun.sh" | install /dev/stdin /usr/local/bin/quick-sharun.sh
EOR

# Build and install
ARG TARGETOS TARGETARCH TARGETVARIANT
ARG APPNAME=sdgyrodsu
ARG OWNER=owner
COPY . /work
WORKDIR /work
RUN <<EOR
  set -eu

  make

  arch=$(uname -m)
  export APPNAME
  export DESKTOP="pkg/${APPNAME}.desktop"
  export ICON="pkg/${APPNAME}.svg"
  export VERSION=$(timeout 1 "bin/release/${APPNAME}" | sed -nE 's/.*Version: (.+)$/\1/p')
  export UPINFO="gh-releases-zsync|${OWNER}|${APPNAME}|latest|${APPNAME}-*-${arch}.AppImage.zsync"
  export OUTPATH=/appimage

  quick-sharun.sh "bin/release/${APPNAME}"
  quick-sharun.sh --make-appimage
EOR

# Keep only files required for runtime
FROM scratch AS export-stage
COPY --from=build-stage /appimage /
