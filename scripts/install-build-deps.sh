#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    APT_COMMAND="sudo apt-get"
else
    APT_COMMAND="apt-get"
fi

$APT_COMMAND update -q
$APT_COMMAND install -qy --no-install-recommends \
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
    lintian \
    nlohmann-json3-dev \
    libkf5i18n-dev \
    libkf5kio-dev \
    libkf5notifications-dev \
    libkf5solid-dev \
    libkf5syntaxhighlighting-dev \
    libqt5svg5-dev \
    libqt5x11extras5-dev \
    libxcb-icccm4-dev \
    libxcb-shape0-dev \
    qml-module-qtgraphicaleffects \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-shapes \
    qtbase5-dev \
    qtdeclarative5-dev \
    qtquickcontrols2-5-dev
