ARG ESO_IMAGE=ghcr.io/external-secrets/external-secrets:v1.0.0-ubi
ARG VERSION=1.7.1

FROM golang:1.24-bullseye AS builder

ENV CGO_ENABLED=1
ENV GOTOOLCHAIN=auto

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential ca-certificates git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src

ARG VERSION
RUN git clone https://github.com/aws/rolesanywhere-credential-helper.git . && \
    git checkout v${VERSION}

RUN go build \
    -trimpath \
    -ldflags "-X 'github.com/aws/rolesanywhere-credential-helper/cmd.Version=${VERSION}' -w -s" \
    -o /aws_signing_helper \
    main.go

FROM alpine:3.20 AS shell

RUN apk add --no-cache busybox-static && \
    cp /bin/busybox /busybox

FROM ${ESO_IMAGE}

USER 1

COPY --from=builder /aws_signing_helper /usr/local/bin/aws_signing_helper

COPY --from=shell /busybox /usr/bin/sh
COPY --from=shell /busybox /bin/sh
RUN chmod 755 /usr/bin/sh /bin/sh

USER 1000
