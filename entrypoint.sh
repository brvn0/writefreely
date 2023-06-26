#! /bin/sh

cd /go

WRITEFREELY=cmd/writefreely/writefreely

if [ ! -e ./keys/email.aes256 ]; then
    "${WRITEFREELY}" db init && echo "Database initialized!"
    "${WRITEFREELY}" generate keys && echo "Keys generated!"
fi

"${WRITEFREELY}" db migrate

exec "${WRITEFREELY}"
