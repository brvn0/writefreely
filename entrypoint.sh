#! /bin/sh

cd /go

WRITEFREELY=cmd/writefreely/writefreely

if [ ! -e ./keys/email.aes256 ]; then
"${WRITEFREELY}" generate keys && echo "Keys generated!"
"${WRITEFREELY}" db init && echo "Database initialized!"   
fi

"${WRITEFREELY}" db migrate

exec "${WRITEFREELY}"
