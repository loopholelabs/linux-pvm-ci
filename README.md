# Linux PVM CI

Kernel package CI for Linux with PVM patches applied

[![Kernel CI](https://github.com/loopholelabs/linux-pvm-ci/actions/workflows/kernel.yaml/badge.svg)](https://github.com/loopholelabs/linux-pvm-ci/actions/workflows/kernel.yaml)

## Overview

🚧 This project is a work-in-progress! Instructions will be added as soon as it is usable. 🚧

## Installation

> Replace all occurrences of `fedora` to your distribution of choice (valid values are: `fedora`, `rocky`, `alma`) and `hetzner` to your cloud provider of choice (valid values are: `baremetal`, `hetzner`, `digitalocean`, `aws`, `gcp`, `equinix`, `ovh`, `azure`, `civo`, `linode`)

> Note that saving and restoring a snapshot between 4-level paging mode hosts (such as older AWS machine models) and 5-level paging mode hosts (such as newer GCP machine models) is not possible at this time (see [https://github.com/virt-pvm/linux/issues/6#issuecomment-2076990347](https://github.com/virt-pvm/linux/issues/6#issuecomment-2076990347))

> We set `lapic=notscdeadline` on the host to fix freezes during snapshot restores to work around [https://github.com/firecracker-microvm/firecracker/issues/4099](https://github.com/firecracker-microvm/firecracker/issues/4099)

### With `cloud-init`

```yaml
#cloud-config
runcmd:
  - dnf config-manager --add-repo 'https://loopholelabs.github.io/linux-pvm-ci/fedora/hetzner/repodata/linux-pvm-ci.repo'
  - dnf install -y kernel-6.7.0_rc6_pvm_host_fedora_hetzner-1.x86_64
  - grubby --set-default /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner
  - grubby --args="pti=off nokaslr lapic=notscdeadline" --update-kernel /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner
  - reboot

write_files:
  - path: /etc/modprobe.d/kvm-intel-amd-blacklist.conf
    permissions: "0644"
    content: |
      blacklist kvm-intel
      blacklist kvm-amd
  - path: /etc/modules-load.d/kvm-pvm.conf
    permissions: "0644"
    content: |
      kvm-pvm

power_state:
  mode: reboot
  condition: True
```

### Manually

```shell
sudo dnf config-manager --add-repo 'https://loopholelabs.github.io/linux-pvm-ci/fedora/hetzner/repodata/linux-pvm-ci.repo'
sudo dnf install -y kernel-6.7.0_rc6_pvm_host_fedora_hetzner-1.x86_64
```

```shell
sudo grubby --set-default /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner
sudo grubby --args="pti=off nokaslr lapic=notscdeadline" --update-kernel /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner
```

```shell
sudo tee /etc/modprobe.d/kvm-intel-amd-blacklist.conf <<EOF
blacklist kvm-intel
blacklist kvm-amd
EOF
echo "kvm-pvm" | sudo tee /etc/modules-load.d/kvm-pvm.conf
```

```shell
sudo reboot
```

```shell
lsmod | grep pvm # Check if PVM is available
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/loopholelabs/linux-pvm-ci][gitrepo]. For more contribution information check out [the contribution guide](https://github.com/loopholelabs/linux-pvm-ci/blob/master/CONTRIBUTING.md).

## License

The Linux PVM CI project is available as open source under the terms of the [GNU General Public License, Version 2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html).

## Code of Conduct

Everyone interacting in the Linux PVM CI project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [CNCF Code of Conduct](https://github.com/cncf/foundation/blob/master/code-of-conduct.md).

## Project Managed By:

[![https://loopholelabs.io][loopholelabs]](https://loopholelabs.io)

[gitrepo]: https://github.com/loopholelabs/linux-pvm-ci
[loopholelabs]: https://cdn.loopholelabs.io/loopholelabs/LoopholeLabsLogo.svg
[loophomepage]: https://loopholelabs.io
