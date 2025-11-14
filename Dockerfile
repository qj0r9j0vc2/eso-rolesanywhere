ARG ESO_IMAGE=ghcr.io/external-secrets/external-secrets:v0.10.0

# --------------------------------------------
# Stage 1: Download AWS Signing Helper
# --------------------------------------------
FROM alpine:3.20 AS helper

ARG AWS_SIGNING_HELPER_VERSION=1.7.1
ARG AWS_SIGNING_HELPER_ARCH=X86_64
ARG AWS_SIGNING_HELPER_OS=Linux
ARG AWS_SIGNING_HELPER_DISTRO=Amzn2023

RUN apk add --no-cache curl \
  && curl -fL --show-error \
       -o /aws_signing_helper \
       "https://rolesanywhere.amazonaws.com/releases/${AWS_SIGNING_HELPER_VERSION}/${AWS_SIGNING_HELPER_ARCH}/${AWS_SIGNING_HELPER_OS}/${AWS_SIGNING_HELPER_DISTRO}/aws_signing_helper" \
  && chmod +x /aws_signing_helper

# --------------------------------------------
# Stage 2: Inject helper into ESO Image
# --------------------------------------------
FROM ${ESO_IMAGE}

FROM ${ESO_IMAGE}

COPY --from=helper /aws_signing_helper /usr/local/bin/aws_signing_helper

