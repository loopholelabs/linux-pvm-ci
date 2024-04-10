SHELL := /bin/bash
BASEURL := https://loopholelabs.github.io/linux-pvm-ci/

obj = fedora/hetzner rocky/hetzner alma/hetzner
all: $(addprefix build/,$(obj))

clone:
	rm -rf work/base/linux
	mkdir -p work/base/linux
	git clone --depth 1 --single-branch --branch pvm-fix https://github.com/virt-pvm/linux.git work/base/linux

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
	 	git apply ../../../../patches/fix-installkernel.patch

patch/fedora/hetzner: patch/pre/fedora/hetzner

patch/rocky/hetzner: patch/pre/rocky/hetzner

patch/alma/hetzner: patch/pre/alma/hetzner

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

configure/fedora/hetzner: configure/pre/fedora/hetzner

configure/rocky/hetzner: configure/pre/rocky/hetzner

configure/alma/hetzner: configure/pre/alma/hetzner

build: $(addprefix build/,$(obj))
$(addprefix build/pre/,$(obj)):
	rm -rf work/$(subst build/pre/,,$@)/linux/rpmbuild
	echo '0' > work/$(subst build/pre/,,$@)/linux/.version

$(addprefix build/post/,$(obj)):
	mkdir -p out/$(subst build/post/,,$@)
	cp work/$(subst build/post/,,$@)/linux/rpmbuild/RPMS/x86_64/*.rpm out/$(subst build/post/,,$@)

build/fedora/hetzner: build/pre/fedora/hetzner
	cd work/fedora/hetzner/linux && yes "" | $(MAKE) LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-hetzner rpm-pkg
	$(MAKE) build/post/fedora/hetzner

build/rocky/hetzner: build/pre/rocky/hetzner
	cd work/rocky/hetzner/linux && yes "" | $(MAKE) LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-rocky-hetzner rpm-pkg
	$(MAKE) build/post/rocky/hetzner

build/alma/hetzner: build/pre/alma/hetzner
	cd work/alma/hetzner/linux && yes "" | $(MAKE) LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-alma-hetzner rpm-pkg
	$(MAKE) build/post/alma/hetzner

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

package/fedora/hetzner: package/pre/fedora/hetzner

package/rocky/hetzner: package/pre/rocky/hetzner

package/alma/hetzner: package/pre/alma/hetzner

clean: $(addprefix clean/,$(obj))
	rm -rf work/base out

$(addprefix clean/,$(obj)):
	rm -rf work/$(subst clean/,,$@)
