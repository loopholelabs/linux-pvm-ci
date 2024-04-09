#!/bin/bash

set -ex

cd ./fedora-hetzner/linux

export CC="ccache gcc"

rm -rf rpmbuild
echo "0" >.version
yes "" | make -j$(nproc) LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-hetzner rpm-pkg

mkdir -p ../../out
cp rpmbuild/RPMS/x86_64/*.rpm ../../out
