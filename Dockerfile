ARG ESO_IMAGE=ghcr.io/external-secrets/external-secrets:v1.0.0-ubi

FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS helper

ARG AWS_SIGNING_HELPER_VERSION=1.7.1
ARG AWS_SIGNING_HELPER_ARCH=X86_64
ARG AWS_SIGNING_HELPER_OS=Linux
ARG AWS_SIGNING_HELPER_DISTRO=Amzn2023

RUN curl -fL --show-error \
      -o /usr/local/bin/aws_signing_helper \
      "https://rolesanywhere.amazonaws.com/releases/${AWS_SIGNING_HELPER_VERSION}/${AWS_SIGNING_HELPER_ARCH}/${AWS_SIGNING_HELPER_OS}/${AWS_SIGNING_HELPER_DISTRO}/aws_signing_helper" \
    && chmod +x /usr/local/bin/aws_signing_helper \
    && mkdir -p /aws-libs \
    && ldd /usr/local/bin/aws_signing_helper \
         | awk '/=> \// {print $3}' > /tmp/aws-helper-libs.txt \
    && while read -r lib; do \
         [ -f "$lib" ] && cp -v "$lib" /aws-libs/; \
       done < /tmp/aws-helper-libs.txt

FROM ${ESO_IMAGE}

USER root

COPY --from=helper /usr/local/bin/aws_signing_helper /usr/local/bin/aws_signing_helper

COPY --from=helper /aws-libs/* /lib64/

USER 1000
