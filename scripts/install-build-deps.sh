#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2025-2026 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Check if running as root.

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt"
else
    APT_COMMAND="apt"
fi


# -- Install build packages.

$APT_COMMAND update -q
$APT_COMMAND install -y - --no-install-recommends \
    appstream \
    automake \
    autotools-dev \
    build-essential \
    checkinstall \
    cmake \
    curl \
    devscripts \
    equivs \
    extra-cmake-modules \
    gettext \
    git \
    gnupg2 \
    libkf6coreaddons-dev \
    libkf6i18n-dev \
    libkf6notifications-dev \
    libkf6windowsystem-dev \
    libxcb-icccm4-dev \
    libxcb-shape0-dev \
    lintian \
    nlohmann-json3-dev \
    qml-module-qtgraphicaleffects \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-shapes \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-multimedia-dev \
    qt6-svg-dev


# -- Add package from our repository.

mkdir -p /etc/apt/keyrings

curl -fsSL https://packagecloud.io/nitrux/mauikit/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nitrux-mauikit.gpg

cat <<EOF > /etc/apt/sources.list.d/nitrux-mauikit.sources
Types: deb
Description: Nitrux MauiKit Repo
URIs: https://packagecloud.io/nitrux/mauikit/debian/
Suites: duke
Components: main
Signed-By: /etc/apt/keyrings/nitrux-mauikit.gpg
Enabled: yes
EOF

$APT_COMMAND update -q
$APT_COMMAND install -y - --no-install-recommends \
    maui-manager
