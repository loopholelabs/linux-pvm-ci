SHELL := /bin/bash

obj = fedora/hetzner
all: $(addprefix build/,$(obj))

clone:
	rm -rf work/base/linux
	mkdir -p work/base/linux
	git clone --depth 1 --single-branch --branch pvm-fix https://github.com/virt-pvm/linux.git work/base/linux

copy: $(addprefix copy/,$(obj))
copy/fedora/hetzner:
	rm -rf work/fedora/hetzner
	mkdir -p work/fedora/hetzner
	cp -r work/base/linux work/fedora/hetzner/linux

patch: $(addprefix patch/,$(obj))
patch/fedora/hetzner:
	cd work/fedora/hetzner/linux && \
	 	git apply ../../../../patches/add-typedefs.patch && \
	 	git apply ../../../../patches/fix-installkernel.patch

configure: $(addprefix configure/,$(obj))
# KVM_PVM: To enable PVM
# ADDRESS_MASKING: To prevent https://lore.kernel.org/all/CAHk-=wiOJOOyWvZOUsKppD068H3D=5dzQOJv5j2DU4rDPsJBBg@mail.gmail.com/T/
# DEBUG_INFO_NONE etc.: To build the RPM much more quickly
# SYSTEM_TRUSTED_KEYS: To auto-generate certs
configure/fedora/hetzner:
	cp configs/fedora/hetzner.config work/fedora/hetzner/linux/.config
	cd work/fedora/hetzner/linux && \
		yes "" | $(MAKE) oldconfig && \
		scripts/config -m KVM_PVM && \
		scripts/config -d ADDRESS_MASKING && \
		scripts/config -e DEBUG_INFO_NONE && \
		scripts/config -d DEBUG_INFO_BTF && \
		scripts/config -d DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT && \
		scripts/config -d DEBUG_INFO_DWARF4 && \
		scripts/config -d DEBUG_INFO_DWARF5 && \
		scripts/config --set-str SYSTEM_TRUSTED_KEYS ""

build: $(addprefix build/,$(obj))
build/fedora/hetzner:
	rm -rf work/fedora/hetzner/linux/rpmbuild
	echo '0' > work/fedora/hetzner/linux/.version
	cd work/fedora/hetzner/linux && yes "" | CC="ccache gcc" $(MAKE) LOCALVERSION= EXTRAVERSION=-rc6-pvm-host-fedora-hetzner rpm-pkg
	mkdir -p out/fedora/hetzner
	cp work/fedora/hetzner/linux/rpmbuild/RPMS/x86_64/*.rpm out/fedora/hetzner

package: $(addprefix package/,$(obj))
package/fedora/hetzner:
	rpm --addsign out/fedora/hetzner/*.rpm
	createrepo out/fedora/hetzner
	gpg --detach-sign --armor --default-key $(shell echo ${PGP_KEY_ID_BASE64} | base64 -d) "out/fedora/hetzner/repodata/repomd.xml"
	gpg --output "out/fedora/hetzner/repodata/repo.asc" --armor --export --default-key $(shell echo ${PGP_KEY_ID_BASE64} | base64 -d)
	printf "[linux-pvm-ci]\n\
	name=Linux PVM Repository\n\
	baseurl=https://loopholelabs.github.io/linux-pvm-ci/fedora/hetzner\n\
	enabled=1\n\
	gpgcheck=1\n\
	gpgkey=https://loopholelabs.github.io/linux-pvm-ci/fedora/hetzner/repodata/repo.asc" > "out/fedora/hetzner/repodata/linux-pvm-ci.repo"

clean: $(addprefix clean/,$(obj))
	rm -rf work/base out

$(addprefix clean/,$(obj)):
	rm -rf work/$(subst clean/,,$@)
