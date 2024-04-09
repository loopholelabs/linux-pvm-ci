#!/bin/bash

set -ex

rm -rf fedora-hetzner/linux
cp -r base/linux fedora-hetzner/linux

cp fedora-hetzner/.config fedora-hetzner/linux/.config

cd fedora-hetzner/linux/

yes "" | make oldconfig

scripts/config -m KVM_PVM
scripts/config -d ADDRESS_MASKING                    # To prevent https://lore.kernel.org/all/CAHk-=wiOJOOyWvZOUsKppD068H3D=5dzQOJv5j2DU4rDPsJBBg@mail.gmail.com/T/
scripts/config -d DEBUG_INFO_BTF                     # To prevent https://lore.kernel.org/all/CAHk-=wiOJOOyWvZOUsKppD068H3D=5dzQOJv5j2DU4rDPsJBBg@mail.gmail.com/T/
scripts/config -e DEBUG_INFO_NONE                    # To build the RPM much more quickly: https://stackoverflow.com/questions/62737956/compressing-all-files-inside-linux-kernel-rpm-package
scripts/config -d DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT # To disable debug info
scripts/config -d DEBUG_INFO_DWARF4                  # To disable debug info
scripts/config -d DEBUG_INFO_DWARF5                  # To disable debug info
scripts/config --set-str SYSTEM_TRUSTED_KEYS ""      # To not require secureboot certs
