FROM fedora:40

RUN dnf group install -y "Development Tools"
RUN dnf install -y fedora-packager rpmdevtools perl ccache rpm-sign
RUN dnf builddep -y kernel
