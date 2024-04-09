#!/bin/bash

set -ex

echo "${PGP_KEY_PASSWORD}" | base64 -d >'/tmp/pgp-pass'
mkdir -p "${HOME}/.gnupg"
cat >"${HOME}/.gnupg/gpg.conf" <<EOT
yes
passphrase-file /tmp/pgp-pass
pinentry-mode loopback
EOT

echo "${PGP_KEY}" | base64 -d >'/tmp/private.pgp'
gpg --import /tmp/private.pgp

echo "%_signature gpg
%_gpg_name $(echo ${PGP_KEY_ID} | base64 -d)" >"${HOME}/.rpmmacros"
