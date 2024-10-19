SHELL := /bin/bash
REPO := https://github.com/loopholelabs/linux-pvm.git
BASEURL := https://loopholelabs.github.io/linux-pvm-ci/

obj = fedora/baremetal fedora/hetzner fedora/digitalocean fedora/aws fedora/gcp fedora/ovh fedora/linode \
      rocky/baremetal rocky/hetzner rocky/digitalocean rocky/aws rocky/gcp rocky/equinix rocky/ovh rocky/azure rocky/civo rocky/linode \
      alma/baremetal alma/hetzner alma/digitalocean alma/aws alma/gcp alma/equinix alma/ovh alma/azure alma/linode
all: $(addprefix build/,$(obj))

clone:
	rm -rf work/base/linux
	mkdir -p work/base/linux
	git clone --depth 1 --single-branch --branch pvm-v6.7 ${REPO} work/base/linux

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
	 	git apply ../../../../patches/fix-rpmbuild.patch

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
patch/rocky/equinix: patch/pre/rocky/equinix
patch/rocky/ovh: patch/pre/rocky/ovh
patch/rocky/azure: patch/pre/rocky/azure
patch/rocky/civo: patch/pre/rocky/civo
patch/rocky/linode: patch/pre/rocky/linode

patch/alma/baremetal: patch/pre/alma/baremetal
patch/alma/hetzner: patch/pre/alma/hetzner
patch/alma/digitalocean: patch/pre/alma/digitalocean
patch/alma/aws: patch/pre/alma/aws
patch/alma/gcp: patch/pre/alma/gcp
patch/alma/equinix: patch/pre/alma/equinix
patch/alma/ovh: patch/pre/alma/ovh
patch/alma/azure: patch/pre/alma/azure
patch/alma/linode: patch/pre/alma/linode

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
configure/rocky/equinix: configure/pre/rocky/equinix
configure/rocky/ovh: configure/pre/rocky/ovh
configure/rocky/azure: configure/pre/rocky/azure
configure/rocky/civo: configure/pre/rocky/civo
configure/rocky/linode: configure/pre/rocky/linode

configure/alma/baremetal: configure/pre/alma/baremetal
configure/alma/hetzner: configure/pre/alma/hetzner
configure/alma/digitalocean: configure/pre/alma/digitalocean
configure/alma/aws: configure/pre/alma/aws
configure/alma/gcp: configure/pre/alma/gcp
configure/alma/equinix: configure/pre/alma/equinix
configure/alma/ovh: configure/pre/alma/ovh
configure/alma/azure: configure/pre/alma/azure
configure/alma/linode: configure/pre/alma/linode

build: $(addprefix build/,$(obj))
$(addprefix build/pre/,$(obj)):
	rm -rf work/$(subst build/pre/,,$@)/linux/rpmbuild
	echo '0' > work/$(subst build/pre/,,$@)/linux/.version

$(addprefix build/post/,$(obj)):
	mkdir -p out/$(subst build/post/,,$@)
	cp work/$(subst build/post/,,$@)/linux/rpmbuild/RPMS/x86_64/*.rpm out/$(subst build/post/,,$@)

build/fedora/baremetal: build/pre/fedora/baremetal
	cd work/fedora/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-baremetal rpm-pkg
	$(MAKE) build/post/fedora/baremetal
build/fedora/hetzner: build/pre/fedora/hetzner
	cd work/fedora/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-hetzner rpm-pkg
	$(MAKE) build/post/fedora/hetzner
build/fedora/digitalocean: build/pre/fedora/digitalocean
	cd work/fedora/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-digitalocean rpm-pkg
	$(MAKE) build/post/fedora/digitalocean
build/fedora/aws: build/pre/fedora/aws
	cd work/fedora/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-aws rpm-pkg
	$(MAKE) build/post/fedora/aws
build/fedora/gcp: build/pre/fedora/gcp
	cd work/fedora/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-gcp rpm-pkg
	$(MAKE) build/post/fedora/gcp
build/fedora/ovh: build/pre/fedora/ovh
	cd work/fedora/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-ovh rpm-pkg
	$(MAKE) build/post/fedora/ovh
build/fedora/linode: build/pre/fedora/linode
	cd work/fedora/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-linode rpm-pkg
	$(MAKE) build/post/fedora/linode

build/rocky/baremetal: build/pre/rocky/baremetal
	cd work/rocky/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-baremetal rpm-pkg
	$(MAKE) build/post/rocky/baremetal
build/rocky/hetzner: build/pre/rocky/hetzner
	cd work/rocky/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-hetzner rpm-pkg
	$(MAKE) build/post/rocky/hetzner
build/rocky/digitalocean: build/pre/rocky/digitalocean
	cd work/rocky/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-digitalocean rpm-pkg
	$(MAKE) build/post/rocky/digitalocean
build/rocky/aws: build/pre/rocky/aws
	cd work/rocky/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-aws rpm-pkg
	$(MAKE) build/post/rocky/aws
build/rocky/gcp: build/pre/rocky/gcp
	cd work/rocky/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-gcp rpm-pkg
	$(MAKE) build/post/rocky/gcp
build/rocky/equinix: build/pre/rocky/equinix
	cd work/rocky/equinix/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-equinix rpm-pkg
	$(MAKE) build/post/rocky/equinix
build/rocky/ovh: build/pre/rocky/ovh
	cd work/rocky/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-ovh rpm-pkg
	$(MAKE) build/post/rocky/ovh
build/rocky/azure: build/pre/rocky/azure
	cd work/rocky/azure/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-azure rpm-pkg
	$(MAKE) build/post/rocky/azure
build/rocky/civo: build/pre/rocky/civo
	cd work/rocky/civo/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-civo rpm-pkg
	$(MAKE) build/post/rocky/civo
build/rocky/linode: build/pre/rocky/linode
	cd work/rocky/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-linode rpm-pkg
	$(MAKE) build/post/rocky/linode

build/alma/baremetal: build/pre/alma/baremetal
	cd work/alma/baremetal/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-baremetal rpm-pkg
	$(MAKE) build/post/alma/baremetal
build/alma/hetzner: build/pre/alma/hetzner
	cd work/alma/hetzner/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-hetzner rpm-pkg
	$(MAKE) build/post/alma/hetzner
build/alma/digitalocean: build/pre/alma/digitalocean
	cd work/alma/digitalocean/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-digitalocean rpm-pkg
	$(MAKE) build/post/alma/digitalocean
build/alma/aws: build/pre/alma/aws
	cd work/alma/aws/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-aws rpm-pkg
	$(MAKE) build/post/alma/aws
build/alma/gcp: build/pre/alma/gcp
	cd work/alma/gcp/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-gcp rpm-pkg
	$(MAKE) build/post/alma/gcp
build/alma/equinix: build/pre/alma/equinix
	cd work/alma/equinix/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-equinix rpm-pkg
	$(MAKE) build/post/alma/equinix
build/alma/ovh: build/pre/alma/ovh
	cd work/alma/ovh/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-ovh rpm-pkg
	$(MAKE) build/post/alma/ovh
build/alma/azure: build/pre/alma/azure
	cd work/alma/azure/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-azure rpm-pkg
	$(MAKE) build/post/alma/azure
build/alma/linode: build/pre/alma/linode
	cd work/alma/linode/linux && yes "" | KBUILD_BUILD_TIMESTAMP="" $(MAKE) CC="ccache gcc" LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-linode rpm-pkg
	$(MAKE) build/post/alma/linode

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
package/rocky/equinix: package/pre/rocky/equinix
package/rocky/ovh: package/pre/rocky/ovh
package/rocky/azure: package/pre/rocky/azure
package/rocky/civo: package/pre/rocky/civo
package/rocky/linode: package/pre/rocky/linode

package/alma/baremetal: package/pre/alma/baremetal
package/alma/hetzner: package/pre/alma/hetzner
package/alma/digitalocean: package/pre/alma/digitalocean
package/alma/aws: package/pre/alma/aws
package/alma/gcp: package/pre/alma/gcp
package/alma/equinix: package/pre/alma/equinix
package/alma/ovh: package/pre/alma/ovh
package/alma/azure: package/pre/alma/azure
package/alma/linode: package/pre/alma/linode

clean: $(addprefix clean/,$(obj))
	rm -rf work/base out

$(addprefix clean/,$(obj)):
	rm -rf work/$(subst clean/,,$@)
