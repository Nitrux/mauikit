#!/bin/bash

set -eu

### Update sources

mkdir -p /etc/apt/keyrings

curl -fsSL https://packagecloud.io/nitrux/depot/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nitrux_depot-archive-keyring.gpg
curl -fsSL https://packagecloud.io/nitrux/testing/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nitrux_testing-archive-keyring.gpg
curl -fsSL https://packagecloud.io/nitrux/unison/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nitrux_unison-archive-keyring.gpg

cat <<EOF > /etc/apt/sources.list.d/nitrux-depot.list
deb [signed-by=/etc/apt/keyrings/nitrux_depot-archive-keyring.gpg] https://packagecloud.io/nitrux/depot/debian/ trixie main
EOF

cat <<EOF > /etc/apt/sources.list.d/nitrux-testing.list
deb [signed-by=/etc/apt/keyrings/nitrux_testing-archive-keyring.gpg] https://packagecloud.io/nitrux/testing/debian/ trixie main
EOF

cat <<EOF > /etc/apt/sources.list.d/nitrux-unison.list
deb [signed-by=/etc/apt/keyrings/nitrux_unison-archive-keyring.gpg] https://packagecloud.io/nitrux/unison/debian/ trixie main
EOF

apt -q update

### Install Package Build Dependencies #2

apt -q -y install --no-install-recommends \
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

make -j"$(nproc)"

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
	'This package contains the MauiKit shared library, the MauiKit QML module' \
	'and the MauiKit development headers.' \
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
	--maintainer=uri_herrera@nxos.org \
	--provides=mauikit-git \
	--requires="libc6,libqt6core6t64" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
