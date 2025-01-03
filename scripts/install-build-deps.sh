#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt"
else
    APT_COMMAND="apt"
fi

BUILD_DEPS='
    appstream
    automake
    autotools-dev
    build-essential
    checkinstall
    cmake
    curl
    devscripts
    equivs
    extra-cmake-modules
    gettext
    git
    gnupg2
    libkf6coreaddons-dev
    libkf6i18n-dev
    libkf6notifications-dev
    libkf6windowsystem-dev
    libxcb-icccm4-dev
    libxcb-shape0-dev
    lintian
    nlohmann-json3-dev
    qml-module-qtgraphicaleffects
    qml-module-qtquick-controls2
    qml-module-qtquick-shapes
    qt6-base-dev
    qt6-declarative-dev
    qt6-multimedia-dev
    qt6-svg-dev
'

$APT_COMMAND update -q
$APT_COMMAND install -y - --no-install-recommends $BUILD_DEPS