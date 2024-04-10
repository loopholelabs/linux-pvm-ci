# Linux PVM CI for Fedora on Hetzner

## cloud-init

```yaml
#cloud-config
runcmd:
  - dnf config-manager --add-repo 'https://loopholelabs.github.io/linux-pvm-ci/fedora/hetzner/repodata/linux-pvm-ci.repo'
  - dnf install -y kernel-6.7.0_rc6_pvm_host_fedora_hetzner-1.x86_64
  - grubby --set-default /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner
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

## Manual

```shell
sudo dnf config-manager --add-repo 'https://loopholelabs.github.io/linux-pvm-ci/fedora/hetzner/repodata/linux-pvm-ci.repo'
sudo dnf install -y kernel-6.7.0_rc6_pvm_host_fedora_hetzner-1.x86_64
```

```shell
sudo grubby --set-default /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner
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
