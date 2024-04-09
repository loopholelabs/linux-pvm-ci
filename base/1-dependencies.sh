#!/bin/bash

set -ex

sudo dnf group install -y "Development Tools"
sudo dnf install -y fedora-packager rpmdevtools perl ccache rpm-sign
sudo dnf builddep -y kernel
