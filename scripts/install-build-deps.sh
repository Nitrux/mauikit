#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Check if running as root.

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt"
else
    APT_COMMAND="apt"
fi



# -- Add third-aprty repository keys.

add_repo_key_and_source() {
    local key_id="$1"
    local keyring_file="$2"
    local source_file="$3"
    local source_content="$4"

    if ! gpg --list-keys "$key_id" &>/dev/null; then
        gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key_id"
    fi

    if ! [ -f "$keyring_file" ] || ! gpg --quiet --with-colons --import-options show-only --import "$keyring_file" | grep -q "$key_id"; then
        gpg --batch --yes --export "$key_id" | gpg --dearmor -o "$keyring_file"
    fi

    if ! grep -Fxq "$source_content" "$source_file" 2>/dev/null; then
        echo "$source_content" > "$source_file"
    fi
}

add_repo_key_and_source \
    "E6D4736255751E5D" \
    "/etc/apt/keyrings/kde_neon-archive-keyring.gpg" \
    "/etc/apt/sources.list.d/neon-repo.list" \
    "deb [signed-by=/etc/apt/keyrings/kde_neon-archive-keyring.gpg] https://origin.archive.neon.kde.org/stable/ jammy main"


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

curl -fsSL https://packagecloud.io/nitrux/zbkit/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nitrux_zbkit-archive-keyring.gpg

cat <<EOF > /etc/apt/sources.list.d/nitrux-zbkit.list
deb [signed-by=/etc/apt/keyrings/nitrux_zbkit-archive-keyring.gpg] https://packagecloud.io/nitrux/zbkit/debian/ bullseye main
EOF

$APT_COMMAND update -q
$APT_COMMAND install -y - --no-install-recommends \
    maui-manager
