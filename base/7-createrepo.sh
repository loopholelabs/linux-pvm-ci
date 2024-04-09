#!/bin/bash

set -ex

cd out

rpm --addsign *.rpm

createrepo .

gpg --detach-sign --armor --default-key $(echo ${PGP_KEY_ID} | base64 -d) "repodata/repomd.xml"

gpg --output "repodata/repo.asc" --armor --export --default-key $(echo ${PGP_KEY_ID} | base64 -d)

echo "[linux-pvm-ci-repo]
name=Linux PVM repo
baseurl=https://loopholelabs.github.io/linux-pvm-ci
enabled=1
gpgcheck=1
gpgkey=https://loopholelabs.github.io/linux-pvm-ci/repodata/repo.asc" >"repodata/linux-pvm-ci.repo"
