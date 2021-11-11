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
### DO NOT USE debuild,screw it

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
	--pkgname=mauikit \
	--pkgversion=2.1.0 \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=lib
	--pkgsource=mauikit
	--pakdir=../.. \
	--maintainer="Uri Herrera <uri_herrera@nxos.org>" \
	--provides=libmauikit,mauikit-dev,qml-module-org-kde-mauikit \
	--requires=libc6,libkf5configcore5,libkf5coreaddons5,libkf5i18n5,libkf5notifications5,libqt5core5a,libqt5gui5,libqt5qml5,libstdc++6,qml-module-org-kde-kirigami2,qml-module-qtquick-controls2,qml-module-qtquick-shapes \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes
