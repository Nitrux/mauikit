#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2025-2026 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -euo pipefail

# -- Prepare source.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
PACKAGE_VERSION="${PACKAGE_VERSION:-0.0.1}"
TARGET_ARCH="${TARGET_ARCH:-$(dpkg --print-architecture)}"

# -- Download Source

git clone --depth 1 --branch "${MAUIKIT_BRANCH}" https://github.com/Nitrux/mauikit-src.git "$repo_root/mauikit-src"
source_dir="$repo_root/mauikit-src"

# -- Configure build.

build_dir="$repo_root/build"
meson_dir="$build_dir/meson"
stage_dir="$build_dir/package"
rm -rf "$meson_dir" "$stage_dir"
mkdir -p "$build_dir"

meson_args=(--prefix=/usr --buildtype=release)
if [ "$(dpkg-architecture -qDEB_HOST_ARCH)" = "amd64" ]; then
    meson_args+=("-Dcpp_args=-march=x86-64-v3")
fi

# -- Compile Source

meson setup "$meson_dir" "$source_dir" "${meson_args[@]}"
meson compile -C "$meson_dir" -j "$(nproc)"

# -- Install source to DESTDIR.

DESTDIR="$stage_dir" meson install -C "$meson_dir"

style_qmldir="$(find "$stage_dir/usr" -type f -path '*/qt6/qml/org/mauikit/style/qmldir' -print -quit)"
style_plugin="$(find "$stage_dir/usr" -type f -name 'libMauiStyle.so' -print -quit)"
if [ -z "$style_qmldir" ] || [ -z "$style_plugin" ]; then
    echo "MauiKit style QML module was not installed." >&2
    exit 1
fi

# -- Create DEBIAN control file.

mkdir -p "$stage_dir/DEBIAN"
cat > "$stage_dir/DEBIAN/control" <<CONTROL
Package: mauikit
Version: ${PACKAGE_VERSION}
Section: libs
Priority: optional
Architecture: ${TARGET_ARCH}
Maintainer: uri_herrera@nxos.org
Provides: mauikit-git
Depends: libc6,libkf6coreaddons6,libkf6i18n6,libkf6notifications6,libkf6windowsystem6,libqt6core6t64,libqt6gui6,libqt6qml6,libqt6quick6,libqt6quickcontrols2-6,libqt6quickshapes6,libqt6svg6,libqt6svgwidgets6,maui-manager (>= 4.0.4),qml6-module-org-kde-kirigami,qml6-module-qtquick-controls,qml6-module-qtquick-shapes,libxkbcommon0
Description: mauikit
 mauikit
CONTROL

# -- Create .deb.

dpkg-deb --build --root-owner-group "$stage_dir" "$build_dir/mauikit_${PACKAGE_VERSION}_${TARGET_ARCH}.deb"
