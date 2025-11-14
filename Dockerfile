ARG ESO_IMAGE=ghcr.io/external-secrets/external-secrets:v1.0.0-ubi

FROM alpine:3.20 AS helper

ARG AWS_SIGNING_HELPER_VERSION=1.7.0
ARG AWS_SIGNING_HELPER_ARCH=X86_64
ARG AWS_SIGNING_HELPER_OS=Linux

RUN apk add --no-cache curl \
  && curl -fL --show-error \
       -o /aws_signing_helper \
       "https://rolesanywhere.amazonaws.com/releases/${AWS_SIGNING_HELPER_VERSION}/${AWS_SIGNING_HELPER_ARCH}/${AWS_SIGNING_HELPER_OS}/aws_signing_helper" \
  && chmod +x /aws_signing_helper

FROM ${ESO_IMAGE}

USER root

COPY --from=helper /aws_signing_helper /usr/local/bin/aws_signing_helper

USER 1000
