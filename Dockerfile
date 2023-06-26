# Build image
FROM golang:1.19-alpine as build

RUN apk add --update nodejs npm make g++ git
RUN npm install -g less less-plugin-clean-css

RUN mkdir -p /go/src/github.com/writefreely/writefreely
WORKDIR /go/src/github.com/writefreely/writefreely

COPY . .

RUN cat ossl_legacy.cnf > /etc/ssl/openssl.cnf

ENV GO111MODULE=on
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN make build \
  && make ui

RUN echo '\
  #!/bin/bash \
set -e \
cd /go \
WRITEFREELY=cmd/writefreely/writefreely \
if [ ! -e ./keys/email.aes256 ]; then \
  "${WRITEFREELY}" db init \
  "${WRITEFREELY}" generate keys \
fi \
"${WRITEFREELY}" db migrate \
exec "${WRITEFREELY}"' > entrypoint.sh \
  && chmod +x entrypoint.sh

RUN mkdir /stage && \
    cp -R /go/bin \
      /go/src/github.com/writefreely/writefreely/templates \
      /go/src/github.com/writefreely/writefreely/static \
      /go/src/github.com/writefreely/writefreely/pages \
      /go/src/github.com/writefreely/writefreely/keys \
      /go/src/github.com/writefreely/writefreely/cmd \
      entrypoint.sh \
      /stage

# Final image
FROM alpine:3

RUN apk add --no-cache openssl ca-certificates
COPY --from=build --chown=daemon:daemon /stage /go

WORKDIR /go
VOLUME /go/keys
EXPOSE 8080
USER daemon

# ENTRYPOINT ["cmd/writefreely/writefreely"]
ENTRYPOINT ["./entrypoint.sh"]
