ARG ESO_IMAGE=ghcr.io/external-secrets/external-secrets:v1.0.0-ubi
ARG AWS_SIGNING_HELPER_VERSION=1.7.1
ARG AWS_SIGNING_HELPER_ARCH=X86_64
ARG AWS_SIGNING_HELPER_OS=Linux
ARG AWS_SIGNING_HELPER_DISTRO=Amzn2023

FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS helper

ARG AWS_SIGNING_HELPER_VERSION
ARG AWS_SIGNING_HELPER_ARCH
ARG AWS_SIGNING_HELPER_OS
ARG AWS_SIGNING_HELPER_DISTRO

RUN dnf install -y findutils && \
    curl -fL --show-error \
      -o /aws_signing_helper \
      "https://rolesanywhere.amazonaws.com/releases/${AWS_SIGNING_HELPER_VERSION}/${AWS_SIGNING_HELPER_ARCH}/${AWS_SIGNING_HELPER_OS}/${AWS_SIGNING_HELPER_DISTRO}/aws_signing_helper" && \
    chmod +x /aws_signing_helper && \
    mkdir -p /aws-root/usr/local/bin /aws-root/opt/aws-libs && \
    cp /aws_signing_helper /aws-root/usr/local/bin/aws_signing_helper && \
    # aws_signing_helper 가 필요로 하는 so 들만 /opt/aws-libs 로 복사
    ldd /aws_signing_helper | awk '/=> \// {print $3}' | sort -u | \
      xargs -I '{}' cp -v '{}' /aws-root/opt/aws-libs/

RUN cat >/aws-root/usr/local/bin/aws_signing_helper_wrapper <<'EOF' \
 && chmod +x /aws-root/usr/local/bin/aws_signing_helper_wrapper
#!/bin/sh
export LD_LIBRARY_PATH=/opt/aws-libs
exec /usr/local/bin/aws_signing_helper "$@"
EOF

FROM ${ESO_IMAGE}

COPY --from=helper /aws-root/ /

