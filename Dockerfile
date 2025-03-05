FROM fedora:41

RUN dnf install -y @development-tools fedora-packager rpmdevtools perl ccache rpm-sign dkms
RUN dnf builddep -y kernel
