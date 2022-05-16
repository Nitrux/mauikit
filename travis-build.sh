#!/bin/bash

set -x

### Install Build Tools #1

DEBIAN_FRONTEND=noninteractive apt -qq update
DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
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
	wget

### Add Neon Sources

wget -qO /etc/apt/sources.list.d/neon-user-repo.list https://raw.githubusercontent.com/Nitrux/iso-tool/development/configs/files/sources.list.neon.user

DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
	55751E5D > /dev/null

DEBIAN_FRONTEND=noninteractive apt -qq update

### Install Package Build Dependencies #2

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends \
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

### Clone Repository

git clone --depth 1 --branch master https://invent.kde.org/maui/mauikit.git

rm -rf mauikit/{demo,LICENSE,README.md}

### Compile Source

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

### Run checkinstall and Build Debian Package
### DO NOT USE debuild, screw it

>> description-pak printf "%s\n" \
	'A free and modular front-end framework for developing user experiences.' \
	'' \
	'MauiKit is a set of templated controls and tools based on QQC2 and Kirigami' \
	'shared among the Maui set of applications.' \
	'' \
	'Maui stands for Multi-Adaptable User Interface and allows ' \
	'any Maui app to run on various platforms + devices,' \
	'like Linux Desktop and Phones, Android, or Windows.' \
	'' \
	'This package contains the MauiKit shared library, the MauiKit qml module' \
	'and the MauiKit development files.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=mauikit-git \
	--pkgversion=2.1.2+git+3 \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=libs \
	--pkgsource=mauikit \
	--pakdir=../.. \
	--maintainer=uri_herrera@nxos.org \
	--provides=mauikit-git \
	--requires=libc6,libkf5configcore5,libkf5coreaddons5,libkf5i18n5,libkf5notifications5,libqt5core5a,libqt5gui5,libqt5qml5,libstdc++6,qml-module-org-kde-kirigami2,qml-module-qtquick-controls2,qml-module-qtquick-shapes \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
