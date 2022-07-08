#!/bin/bash

set -x

apt -qq update
apt -qq -yy install equivs curl git wget gnupg2

### Install Dependencies

DEBIAN_FRONTEND=noninteractive apt -qq -yy install --no-install-recommends devscripts debhelper gettext lintian build-essential automake autotools-dev cmake extra-cmake-modules appstream qml-module-qtquick-controls2 qml-module-qtquick-shapes qml-module-qtgraphicaleffects

mk-build-deps -i -t "apt-get --yes" -r

### Clone repo.

git clone --single-branch --branch v2.0 https://invent.kde.org/maui/mauikit.git

mv mauikit/* .

rm -rf mauikit demo LICENSE README.md

### Build Deb

mkdir source
mv ./* source/ # Hack for debuild
cd source
debuild -b -uc -us
