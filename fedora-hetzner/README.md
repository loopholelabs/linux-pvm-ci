# Linux PVM CI for Fedora on Hetzner

```shell
sudo dnf config-manager --add-repo 'https://loopholelabs.github.io/linux-pvm-ci/repodata/linux-pvm-ci.repo'
sudo dnf install -y --setopt=tsflags=noscripts kernel-6.7.0_rc6_pvm_host_fedora_hetzner-1.x86_64
```

```shell
sudo grubby --add-kernel /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner --title /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner --copy-default --args="pti=off"
sudo grubby --set-default /boot/vmlinuz-6.7.0-rc6-pvm-host-fedora-hetzner
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
```

```shell
sudo tee /etc/modprobe.d/kvm-intel-amd-blacklist.conf <<EOF
blacklist kvm-intel
blacklist kvm-amd
EOF
echo "kvm-pvm" | sudo tee /etc/modules-load.d/kvm-pvm.conf
sudo dracut --regenerate-all --force
```

```shell
sudo reboot
```

```shell
lsmod | grep pvm # Check if PVM is available
```
