ARG ESO_IMAGE=ghcr.io/external-secrets/external-secrets:v0.10.0
ARG AWS_SIGNING_HELPER_VERSION=1.0.5

FROM curlimages/curl:8.7.1 AS downloader

ARG AWS_SIGNING_HELPER_VERSION

RUN apk add --no-cache curl \
  && curl -fL --show-error \
       -o /aws_signing_helper \
       "https://github.com/aws/rolesanywhere-credential-helper/releases/download/v${AWS_SIGNING_HELPER_VERSION}/aws_signing_helper-linux-amd64" \
  && chmod +x /aws_signing_helper

FROM ${ESO_IMAGE}

USER root

COPY --from=downloader /aws_signing_helper /usr/local/bin/aws_signing_helper

RUN mkdir -p /var/aws \
 && chmod 755 /var/aws

USER 1000

