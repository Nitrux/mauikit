#! /bin/bash

set -x

### Update sources

wget -qO /etc/apt/sources.list.d/nitrux-depot.list https://raw.githubusercontent.com/Nitrux/iso-tool/legacy/configs/files/sources/sources.list.nitrux
wget -qO /etc/apt/sources.list.d/nitrux-testing.list https://raw.githubusercontent.com/Nitrux/iso-tool/legacy/configs/files/sources/sources.list.nitrux.testing
wget -qO /etc/apt/sources.list.d/nitrux-unison.list https://raw.githubusercontent.com/Nitrux/iso-tool/legacy/configs/files/sources/sources.list.nitrux.area51
wget -qO /etc/apt/sources.list.d/nitrux-area51.list https://raw.githubusercontent.com/Nitrux/iso-tool/legacy/configs/files/sources/sources.list.nitrux.area51

curl -L https://packagecloud.io/nitrux/depot/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/testing/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/unison/gpgkey | apt-key add -;
curl -L https://packagecloud.io/nitrux/area51/gpgkey | apt-key add -;

apt -qq update

### Install Package Build Dependencies #2

apt -qq -yy install --no-install-recommends \
	maui-manager-git

### Download Source

git clone --depth 1 --branch $MAUIKIT_BRANCH https://invent.kde.org/maui/mauikit.git

rm -rf mauikit/{demo,LICENSE,README.md}

### Compile Source

mkdir -p build && cd build

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
	-DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu ../mauikit/

make -j$(nproc)

make install

### Run checkinstall and Build Debian Package

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
	--pkgversion=$PACKAGE_VERSION \
	--pkgarch=amd64 \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=libs \
	--pkgsource=mauikit \
	--pakdir=. \
	--maintainer=probal31@gmail.com \
	--provides=mauikit-git \
	--requires="libc6,libkf5configcore5,libkf5coreaddons5,libkf5i18n5,libkf5notifications5,libqt5core5a,libqt5gui5,libqt5qml5,libstdc++6,maui-manager-git \(\>= 3.1.0+git\),qml-module-org-kde-kirigami2,qml-module-qtquick-controls2,qml-module-qtquick-shapes" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
