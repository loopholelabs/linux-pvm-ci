#!/bin/bash

set -ex

rm -rf ./base/linux
git clone --depth 1 --single-branch --branch pvm-fix https://github.com/virt-pvm/linux.git ./base/linux # Needed for PVM to also work on AMD
