#!/bin/bash

set -ex

cd ./base/linux

git apply ../*.patch
