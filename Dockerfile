ARG ESO_IMAGE=ghcr.io/external-secrets/external-secrets:v1.0.0-ubi
ARG VERSION=1.7.1

# --- build aws_signing_helper (your current builder) ---
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

# --- UBI stage just to grab a shell + its libs ---
FROM registry.access.redhat.com/ubi9/ubi-minimal AS shellstage

RUN microdnf install -y bash && microdnf clean all

# --- final ESO image ---
FROM ${ESO_IMAGE}

USER root

# aws_signing_helper binary
COPY --from=builder /aws_signing_helper /usr/local/bin/aws_signing_helper

# Provide /bin/sh and the glibc DNS libs it depends on
# (paths may vary slightly; adjust with `rpm -ql glibc` inside shellstage if needed)
COPY --from=shellstage /usr/bin/bash /bin/sh
COPY --from=shellstage /usr/lib64/libresolv.so.2 /usr/lib64/libresolv.so.2
COPY --from=shellstage /usr/lib64/libnss_dns.so.2 /usr/lib64/libnss_dns.so.2
COPY --from=shellstage /usr/lib64/libnss_files.so.2 /usr/lib64/libnss_files.so.2

USER 1000
