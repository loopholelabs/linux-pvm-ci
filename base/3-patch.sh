#!/bin/bash

set -ex

cd ./base/linux

git apply ../add-typedefs.patch
