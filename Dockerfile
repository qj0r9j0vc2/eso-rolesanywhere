ARG ESO_IMAGE=ghcr.io/external-secrets/external-secrets:v1.0.0-ubi

FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git ca-certificates

WORKDIR /src

RUN git clone https://github.com/aws/rolesanywhere-credential-helper.git .

RUN git checkout v1.7.1 || git checkout tags/v1.7.1 -b v1.7.1

ENV VERSION=1.7.1
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOTOOLCHAIN=auto


RUN go build \
    -trimpath \
    -ldflags "-X 'github.com/aws/rolesanywhere-credential-helper/cmd.Version=${VERSION}' -w -s" \
    -o /aws_signing_helper \
    main.go

FROM ${ESO_IMAGE}

USER root

COPY --from=builder /aws_signing_helper /usr/local/bin/aws_signing_helper
RUN chmod +x /usr/local/bin/aws_signing_helper || true

USER 1000
