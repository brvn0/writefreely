#! /bin/sh

set -e

cd /go

WRITEFREELY=cmd/writefreely/writefreely

if [ ! -e ./keys/email.aes256 ]; then
    "${WRITEFREELY}" db init
    "${WRITEFREELY}" generate keys
fi

"${WRITEFREELY}" db migrate

exec "${WRITEFREELY}"
