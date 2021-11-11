#!/bin/bash

set -x

apt -qq update
apt -qq -yy install equivs curl git wget gnupg2 checkinstall

### FIXME - the container mauikit/ubuntu-18.04-amd64 does have the neon repo but for some idiotic reason it isn't working here

wget -qO /etc/apt/sources.list.d/neon-user-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.neon.user

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
	55751E5D > /dev/null

apt -qq update

### Install Dependencies

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends devscripts debhelper gettext lintian build-essential automake autotools-dev cmake extra-cmake-modules appstream qml-module-qtquick-controls2 qml-module-qtquick-shapes qml-module-qtgraphicaleffects

mk-build-deps -i -t "apt-get --yes" -r

### Clone repo.

git clone --depth 1 --branch v2.1 https://invent.kde.org/maui/mauikit.git

mv mauikit/* .

rm -rf mauikit demo LICENSE README.md

### Build Deb
### DO NOT USE debuild, screw it

mkdir -p mauikit/build && cd mauikit/build

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu ..

make

checkinstall -D -y \
  --install=no \
  --fstrans=yes \
  --reset-uids=yes \
  --pkgname=mauikit \
  --pkgversion=2.1.0 \
  --pkgrelease="1" \
  --arch=amd64 \
  --pkglicense=LGPL-3 \
  --maintainer="Uri Herrera <uri_herrera@nxos.org>" \
  --pakdir=../.. \
  --requires=cmake,debhelper,extra-cmake-modules,libkf5i18n-dev,libkf5kio-dev,libkf5notifications-dev,libkf5solid-dev,libkf5syntaxhighlighting-dev,libqt5svg5-dev,libqt5x11extras5-dev,libxcb-icccm4-dev,libxcb-shape0-dev,qml-module-org-kde-kirigami2,qml-module-qtquick-controls2,qml-module-qtquick-shapes,qtbase5-dev,qtdeclarative5-dev,qtquickcontrols2-5-dev