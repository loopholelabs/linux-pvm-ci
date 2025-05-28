SHELL := /bin/bash
REPO := https://github.com/loopholelabs/linux-pvm.git
BASEURL := https://loopholelabs.github.io/linux-pvm-ci/
BRANCH := pvm-v6.7

obj = fedora/baremetal fedora/hetzner fedora/digitalocean fedora/aws fedora/gcp fedora/ovh fedora/linode \
      rocky/baremetal rocky/hetzner rocky/digitalocean rocky/aws rocky/gcp rocky/ovh rocky/azure rocky/civo rocky/linode \
      alma/baremetal alma/hetzner alma/digitalocean alma/aws alma/gcp alma/ovh alma/azure alma/linode \
	  amazonlinux/aws \
+	  fedora-experimental/baremetal fedora-experimental/hetzner fedora-experimental/digitalocean fedora-experimental/aws fedora-experimental/gcp fedora-experimental/ovh fedora-experimental/linode \
      rocky-experimental/baremetal rocky-experimental/hetzner rocky-experimental/digitalocean rocky-experimental/aws rocky-experimental/gcp rocky-experimental/ovh rocky-experimental/azure rocky-experimental/civo rocky-experimental/linode \
      alma-experimental/baremetal alma-experimental/hetzner alma-experimental/digitalocean alma-experimental/aws alma-experimental/gcp alma-experimental/ovh alma-experimental/azure alma-experimental/linode \
      amazonlinux-experimental/aws
all: $(addprefix build/,$(obj))

clone:
	rm -rf work/base/linux
	mkdir -p work/base/linux
	git clone --depth 1 --single-branch --branch ${BRANCH} ${REPO} work/base/linux

copy: $(addprefix copy/,$(obj))
$(addprefix copy/,$(obj)):
	rm -rf work/$(subst clean/,,$@)
	rm -rf work/$(subst copy/,,$@)
	mkdir -p work/$(subst copy/,,$@)
	cp -r work/base/linux work/$(subst copy/,,$@)/linux


patch: $(addprefix patch/,$(obj))
$(addprefix patch/pre/,$(obj)):
	cd work/$(subst patch/pre/,,$@)/linux && \
	 	git apply ../../../../patches/add-typedefs.patch && \
	 	git apply ../../../../patches/fix-installkernel.patch && \
		git apply ../../../../patches/use-fixed-pvm-range.patch && \
	 	git apply ../../../../patches/fix-rpmbuild.patch && \
	 	git apply ../../../../patches/fix-signing.patch

patch/fedora/baremetal: patch/pre/fedora/baremetal
patch/fedora/hetzner: patch/pre/fedora/hetzner
patch/fedora/digitalocean: patch/pre/fedora/digitalocean
patch/fedora/aws: patch/pre/fedora/aws
patch/fedora/gcp: patch/pre/fedora/gcp
patch/fedora/ovh: patch/pre/fedora/ovh
patch/fedora/linode: patch/pre/fedora/linode

patch/rocky/baremetal: patch/pre/rocky/baremetal
patch/rocky/hetzner: patch/pre/rocky/hetzner
patch/rocky/digitalocean: patch/pre/rocky/digitalocean
patch/rocky/aws: patch/pre/rocky/aws
patch/rocky/gcp: patch/pre/rocky/gcp
patch/rocky/ovh: patch/pre/rocky/ovh
patch/rocky/azure: patch/pre/rocky/azure
patch/rocky/civo: patch/pre/rocky/civo
patch/rocky/linode: patch/pre/rocky/linode

patch/alma/baremetal: patch/pre/alma/baremetal
patch/alma/hetzner: patch/pre/alma/hetzner
patch/alma/digitalocean: patch/pre/alma/digitalocean
patch/alma/aws: patch/pre/alma/aws
patch/alma/gcp: patch/pre/alma/gcp
patch/alma/ovh: patch/pre/alma/ovh
patch/alma/azure: patch/pre/alma/azure
patch/alma/linode: patch/pre/alma/linode

patch/amazonlinux/aws: patch/pre/amazonlinux/aws

patch/fedora-experimental/baremetal: patch/pre/fedora-experimental/baremetal
patch/fedora-experimental/hetzner: patch/pre/fedora-experimental/hetzner
patch/fedora-experimental/digitalocean: patch/pre/fedora-experimental/digitalocean
patch/fedora-experimental/aws: patch/pre/fedora-experimental/aws
patch/fedora-experimental/gcp: patch/pre/fedora-experimental/gcp
patch/fedora-experimental/ovh: patch/pre/fedora-experimental/ovh
patch/fedora-experimental/linode: patch/pre/fedora-experimental/linode

patch/rocky-experimental/baremetal: patch/pre/rocky-experimental/baremetal
patch/rocky-experimental/hetzner: patch/pre/rocky-experimental/hetzner
patch/rocky-experimental/digitalocean: patch/pre/rocky-experimental/digitalocean
patch/rocky-experimental/aws: patch/pre/rocky-experimental/aws
patch/rocky-experimental/gcp: patch/pre/rocky-experimental/gcp
patch/rocky-experimental/ovh: patch/pre/rocky-experimental/ovh
patch/rocky-experimental/azure: patch/pre/rocky-experimental/azure
patch/rocky-experimental/civo: patch/pre/rocky-experimental/civo
patch/rocky-experimental/linode: patch/pre/rocky-experimental/linode

patch/alma-experimental/baremetal: patch/pre/alma-experimental/baremetal
patch/alma-experimental/hetzner: patch/pre/alma-experimental/hetzner
patch/alma-experimental/digitalocean: patch/pre/alma-experimental/digitalocean
patch/alma-experimental/aws: patch/pre/alma-experimental/aws
patch/alma-experimental/gcp: patch/pre/alma-experimental/gcp
patch/alma-experimental/ovh: patch/pre/alma-experimental/ovh
patch/alma-experimental/azure: patch/pre/alma-experimental/azure
patch/alma-experimental/linode: patch/pre/alma-experimental/linode

patch/amazonlinux-experimental/aws: patch/pre/amazonlinux-experimental/aws

configure: $(addprefix configure/,$(obj))
# KVM_PVM: To enable PVM
# ADDRESS_MASKING: To prevent https://lore.kernel.org/all/CAHk-=wiOJOOyWvZOUsKppD068H3D=5dzQOJv5j2DU4rDPsJBBg@mail.gmail.com/T/
# DEBUG_INFO_NONE etc.: To build the RPM much more quickly
# SYSTEM_TRUSTED_KEYS: To auto-generate certs
$(addprefix configure/pre/,$(obj)):
	cp configs/$(subst configure/pre/,,$@).config work/$(subst configure/pre/,,$@)/linux/.config
	cd work/$(subst configure/pre/,,$@)/linux && \
		yes "" | $(MAKE) oldconfig && \
		scripts/config -m KVM_PVM && \
		scripts/config -d ADDRESS_MASKING && \
		scripts/config -e DEBUG_INFO_NONE && \
		scripts/config -d DEBUG_INFO_BTF && \
		scripts/config -d DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT && \
		scripts/config -d DEBUG_INFO_DWARF4 && \
		scripts/config -d DEBUG_INFO_DWARF5 && \
		scripts/config --set-str SYSTEM_TRUSTED_KEYS ""

configure/fedora/baremetal: configure/pre/fedora/baremetal
configure/fedora/hetzner: configure/pre/fedora/hetzner
configure/fedora/digitalocean: configure/pre/fedora/digitalocean
configure/fedora/aws: configure/pre/fedora/aws
configure/fedora/gcp: configure/pre/fedora/gcp
configure/fedora/ovh: configure/pre/fedora/ovh
configure/fedora/linode: configure/pre/fedora/linode

configure/rocky/baremetal: configure/pre/rocky/baremetal
configure/rocky/hetzner: configure/pre/rocky/hetzner
configure/rocky/digitalocean: configure/pre/rocky/digitalocean
configure/rocky/aws: configure/pre/rocky/aws
configure/rocky/gcp: configure/pre/rocky/gcp
configure/rocky/ovh: configure/pre/rocky/ovh
configure/rocky/azure: configure/pre/rocky/azure
configure/rocky/civo: configure/pre/rocky/civo
configure/rocky/linode: configure/pre/rocky/linode

configure/alma/baremetal: configure/pre/alma/baremetal
configure/alma/hetzner: configure/pre/alma/hetzner
configure/alma/digitalocean: configure/pre/alma/digitalocean
configure/alma/aws: configure/pre/alma/aws
configure/alma/gcp: configure/pre/alma/gcp
configure/alma/ovh: configure/pre/alma/ovh
configure/alma/azure: configure/pre/alma/azure
configure/alma/linode: configure/pre/alma/linode

configure/amazonlinux/aws: configure/pre/amazonlinux/aws

configure/fedora-experimental/baremetal: configure/pre/fedora-experimental/baremetal
configure/fedora-experimental/hetzner: configure/pre/fedora-experimental/hetzner
configure/fedora-experimental/digitalocean: configure/pre/fedora-experimental/digitalocean
configure/fedora-experimental/aws: configure/pre/fedora-experimental/aws
configure/fedora-experimental/gcp: configure/pre/fedora-experimental/gcp
configure/fedora-experimental/ovh: configure/pre/fedora-experimental/ovh
configure/fedora-experimental/linode: configure/pre/fedora-experimental/linode

configure/rocky-experimental/baremetal: configure/pre/rocky-experimental/baremetal
configure/rocky-experimental/hetzner: configure/pre/rocky-experimental/hetzner
configure/rocky-experimental/digitalocean: configure/pre/rocky-experimental/digitalocean
configure/rocky-experimental/aws: configure/pre/rocky-experimental/aws
configure/rocky-experimental/gcp: configure/pre/rocky-experimental/gcp
configure/rocky-experimental/ovh: configure/pre/rocky-experimental/ovh
configure/rocky-experimental/azure: configure/pre/rocky-experimental/azure
configure/rocky-experimental/civo: configure/pre/rocky-experimental/civo
configure/rocky-experimental/linode: configure/pre/rocky-experimental/linode

configure/alma-experimental/baremetal: configure/pre/alma-experimental/baremetal
configure/alma-experimental/hetzner: configure/pre/alma-experimental/hetzner
configure/alma-experimental/digitalocean: configure/pre/alma-experimental/digitalocean
configure/alma-experimental/aws: configure/pre/alma-experimental/aws
configure/alma-experimental/gcp: configure/pre/alma-experimental/gcp
configure/alma-experimental/ovh: configure/pre/alma-experimental/ovh
configure/alma-experimental/azure: configure/pre/alma-experimental/azure
configure/alma-experimental/linode: configure/pre/alma-experimental/linode

configure/amazonlinux-experimental/aws: configure/pre/amazonlinux-experimental/aws

build: $(addprefix build/,$(obj))
$(addprefix build/pre/,$(obj)):
	rm -rf work/$(subst build/pre/,,$@)/linux/rpmbuild
	echo '0' > work/$(subst build/pre/,,$@)/linux/.version

$(addprefix build/post/,$(obj)):
	mkdir -p out/$(subst build/post/,,$@)
	cp work/$(subst build/post/,,$@)/linux/rpmbuild/RPMS/x86_64/*.rpm out/$(subst build/post/,,$@)

build/fedora/baremetal: build/pre/fedora/baremetal
	cd work/fedora/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-baremetal-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora/baremetal
build/fedora/hetzner: build/pre/fedora/hetzner
	cd work/fedora/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-hetzner-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora/hetzner
build/fedora/digitalocean: build/pre/fedora/digitalocean
	cd work/fedora/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-digitalocean-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora/digitalocean
build/fedora/aws: build/pre/fedora/aws
	cd work/fedora/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-aws-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora/aws
build/fedora/gcp: build/pre/fedora/gcp
	cd work/fedora/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-gcp-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora/gcp
build/fedora/ovh: build/pre/fedora/ovh
	cd work/fedora/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-ovh-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora/ovh
build/fedora/linode: build/pre/fedora/linode
	cd work/fedora/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-linode-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora/linode

build/rocky/baremetal: build/pre/rocky/baremetal
	cd work/rocky/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-baremetal-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/baremetal
build/rocky/hetzner: build/pre/rocky/hetzner
	cd work/rocky/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-hetzner-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/hetzner
build/rocky/digitalocean: build/pre/rocky/digitalocean
	cd work/rocky/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-digitalocean-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/digitalocean
build/rocky/aws: build/pre/rocky/aws
	cd work/rocky/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-aws-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/aws
build/rocky/gcp: build/pre/rocky/gcp
	cd work/rocky/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-gcp-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/gcp
build/rocky/ovh: build/pre/rocky/ovh
	cd work/rocky/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-ovh-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/ovh
build/rocky/azure: build/pre/rocky/azure
	cd work/rocky/azure/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-azure-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/azure
build/rocky/civo: build/pre/rocky/civo
	cd work/rocky/civo/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-civo-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/civo
build/rocky/linode: build/pre/rocky/linode
	cd work/rocky/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-linode-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky/linode

build/alma/baremetal: build/pre/alma/baremetal
	cd work/alma/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-baremetal-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma/baremetal
build/alma/hetzner: build/pre/alma/hetzner
	cd work/alma/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-hetzner-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma/hetzner
build/alma/digitalocean: build/pre/alma/digitalocean
	cd work/alma/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-digitalocean-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma/digitalocean
build/alma/aws: build/pre/alma/aws
	cd work/alma/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-aws-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma/aws
build/alma/gcp: build/pre/alma/gcp
	cd work/alma/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-gcp-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma/gcp
build/alma/ovh: build/pre/alma/ovh
	cd work/alma/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-ovh-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma/ovh
build/alma/azure: build/pre/alma/azure
	cd work/alma/azure/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-azure-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma/azure
build/alma/linode: build/pre/alma/linode
	cd work/alma/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-linode-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma/linode

build/amazonlinux/aws: build/pre/amazonlinux/aws
	cd work/amazonlinux/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-amazonlinux-aws-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/amazonlinux/aws

build/fedora-experimental/baremetal: build/pre/fedora-experimental/baremetal
	cd work/fedora-experimental/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-experimental-baremetal-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora-experimental/baremetal
build/fedora-experimental/hetzner: build/pre/fedora-experimental/hetzner
	cd work/fedora-experimental/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-experimental-hetzner-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora-experimental/hetzner
build/fedora-experimental/digitalocean: build/pre/fedora-experimental/digitalocean
	cd work/fedora-experimental/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-experimental-digitalocean-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora-experimental/digitalocean
build/fedora-experimental/aws: build/pre/fedora-experimental/aws
	cd work/fedora-experimental/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-experimental-aws-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora-experimental/aws
build/fedora-experimental/gcp: build/pre/fedora-experimental/gcp
	cd work/fedora-experimental/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-experimental-gcp-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora-experimental/gcp
build/fedora-experimental/ovh: build/pre/fedora-experimental/ovh
	cd work/fedora-experimental/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-experimental-ovh-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora-experimental/ovh
build/fedora-experimental/linode: build/pre/fedora-experimental/linode
	cd work/fedora-experimental/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-fedora-experimental-linode-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/fedora-experimental/linode

build/rocky-experimental/baremetal: build/pre/rocky-experimental/baremetal
	cd work/rocky-experimental/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-baremetal-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/baremetal
build/rocky-experimental/hetzner: build/pre/rocky-experimental/hetzner
	cd work/rocky-experimental/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-hetzner-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/hetzner
build/rocky-experimental/digitalocean: build/pre/rocky-experimental/digitalocean
	cd work/rocky-experimental/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-digitalocean-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/digitalocean
build/rocky-experimental/aws: build/pre/rocky-experimental/aws
	cd work/rocky-experimental/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-aws-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/aws
build/rocky-experimental/gcp: build/pre/rocky-experimental/gcp
	cd work/rocky-experimental/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-gcp-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/gcp
build/rocky-experimental/ovh: build/pre/rocky-experimental/ovh
	cd work/rocky-experimental/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-ovh-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/ovh
build/rocky-experimental/azure: build/pre/rocky-experimental/azure
	cd work/rocky-experimental/azure/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-azure-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/azure
build/rocky-experimental/civo: build/pre/rocky-experimental/civo
	cd work/rocky-experimental/civo/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-civo-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/civo
build/rocky-experimental/linode: build/pre/rocky-experimental/linode
	cd work/rocky-experimental/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-rocky-experimental-linode-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/rocky-experimental/linode

build/alma-experimental/baremetal: build/pre/alma-experimental/baremetal
	cd work/alma-experimental/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-experimental-baremetal-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma-experimental/baremetal
build/alma-experimental/hetzner: build/pre/alma-experimental/hetzner
	cd work/alma-experimental/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-experimental-hetzner-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma-experimental/hetzner
build/alma-experimental/digitalocean: build/pre/alma-experimental/digitalocean
	cd work/alma-experimental/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-experimental-digitalocean-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma-experimental/digitalocean
build/alma-experimental/aws: build/pre/alma-experimental/aws
	cd work/alma-experimental/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-experimental-aws-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma-experimental/aws
build/alma-experimental/gcp: build/pre/alma-experimental/gcp
	cd work/alma-experimental/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-experimental-gcp-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma-experimental/gcp
build/alma-experimental/ovh: build/pre/alma-experimental/ovh
	cd work/alma-experimental/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-experimental-ovh-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma-experimental/ovh
build/alma-experimental/azure: build/pre/alma-experimental/azure
	cd work/alma-experimental/azure/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-experimental-azure-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma-experimental/azure
build/alma-experimental/linode: build/pre/alma-experimental/linode
	cd work/alma-experimental/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-alma-experimental-linode-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/alma-experimental/linode

build/amazonlinux-experimental/aws: build/pre/amazonlinux-experimental/aws
	cd work/amazonlinux-experimental/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION="-pvm-host-amazonlinux-experimental-aws-$(git rev-parse HEAD | head -c 12)" rpm-pkg
	$(MAKE) build/post/amazonlinux-experimental/aws

package: $(addprefix package/,$(obj))
$(addprefix package/pre/,$(obj)):
	rpm --addsign out/$(subst package/pre/,,$@)/*.rpm
	createrepo out/$(subst package/pre/,,$@)
	gpg --detach-sign --armor --default-key $(shell echo ${PGP_KEY_ID} | base64 -d) "out/$(subst package/pre/,,$@)/repodata/repomd.xml"
	gpg --output "out/$(subst package/pre/,,$@)/repodata/repo.asc" --armor --export --default-key $(shell echo ${PGP_KEY_ID} | base64 -d)
	printf "[linux-pvm-ci]\n\
	name=Linux PVM Repository\n\
	baseurl=${BASEURL}/$(subst package/pre/,,$@)\n\
	enabled=1\n\
	gpgcheck=1\n\
	gpgkey=${BASEURL}/$(subst package/pre/,,$@)/repodata/repo.asc" > "out/$(subst package/pre/,,$@)/repodata/linux-pvm-ci.repo"

package/fedora/baremetal: package/pre/fedora/baremetal
package/fedora/hetzner: package/pre/fedora/hetzner
package/fedora/digitalocean: package/pre/fedora/digitalocean
package/fedora/aws: package/pre/fedora/aws
package/fedora/gcp: package/pre/fedora/gcp
package/fedora/ovh: package/pre/fedora/ovh
package/fedora/linode: package/pre/fedora/linode

package/rocky/baremetal: package/pre/rocky/baremetal
package/rocky/hetzner: package/pre/rocky/hetzner
package/rocky/digitalocean: package/pre/rocky/digitalocean
package/rocky/aws: package/pre/rocky/aws
package/rocky/gcp: package/pre/rocky/gcp
package/rocky/ovh: package/pre/rocky/ovh
package/rocky/azure: package/pre/rocky/azure
package/rocky/civo: package/pre/rocky/civo
package/rocky/linode: package/pre/rocky/linode

package/alma/baremetal: package/pre/alma/baremetal
package/alma/hetzner: package/pre/alma/hetzner
package/alma/digitalocean: package/pre/alma/digitalocean
package/alma/aws: package/pre/alma/aws
package/alma/gcp: package/pre/alma/gcp
package/alma/ovh: package/pre/alma/ovh
package/alma/azure: package/pre/alma/azure
package/alma/linode: package/pre/alma/linode

package/amazonlinux/aws: package/pre/amazonlinux/aws

package/fedora-experimental/baremetal: package/pre/fedora-experimental/baremetal
package/fedora-experimental/hetzner: package/pre/fedora-experimental/hetzner
package/fedora-experimental/digitalocean: package/pre/fedora-experimental/digitalocean
package/fedora-experimental/aws: package/pre/fedora-experimental/aws
package/fedora-experimental/gcp: package/pre/fedora-experimental/gcp
package/fedora-experimental/ovh: package/pre/fedora-experimental/ovh
package/fedora-experimental/linode: package/pre/fedora-experimental/linode

package/rocky-experimental/baremetal: package/pre/rocky-experimental/baremetal
package/rocky-experimental/hetzner: package/pre/rocky-experimental/hetzner
package/rocky-experimental/digitalocean: package/pre/rocky-experimental/digitalocean
package/rocky-experimental/aws: package/pre/rocky-experimental/aws
package/rocky-experimental/gcp: package/pre/rocky-experimental/gcp
package/rocky-experimental/ovh: package/pre/rocky-experimental/ovh
package/rocky-experimental/azure: package/pre/rocky-experimental/azure
package/rocky-experimental/civo: package/pre/rocky-experimental/civo
package/rocky-experimental/linode: package/pre/rocky-experimental/linode

package/alma-experimental/baremetal: package/pre/alma-experimental/baremetal
package/alma-experimental/hetzner: package/pre/alma-experimental/hetzner
package/alma-experimental/digitalocean: package/pre/alma-experimental/digitalocean
package/alma-experimental/aws: package/pre/alma-experimental/aws
package/alma-experimental/gcp: package/pre/alma-experimental/gcp
package/alma-experimental/ovh: package/pre/alma-experimental/ovh
package/alma-experimental/azure: package/pre/alma-experimental/azure
package/alma-experimental/linode: package/pre/alma-experimental/linode

package/amazonlinux-experimental/aws: package/pre/amazonlinux-experimental/aws

clean: $(addprefix clean/,$(obj))
	rm -rf work/base out

$(addprefix clean/,$(obj)):
	rm -rf work/$(subst clean/,,$@)
