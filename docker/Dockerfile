FROM alpine:3.14.3

WORKDIR /
EXPOSE 22

RUN apk add --no-cache \
    autossh \
    bind-tools \
    ca-certificates \
    jq \
    openssh \
    openssh-server \
    openssl \
    python3 \
    tzdata && \
    # Deactivate short moduli
    awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.tmp && mv /etc/ssh/moduli.tmp /etc/ssh/moduli

ENV GLIBC_VER=2.31-r0

# install glibc compatibility for alpine
RUN apk --no-cache add \
        binutils \
        curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
        glibc-i18n-${GLIBC_VER}.apk \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip -q awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
        glibc-*.apk \
    && apk --no-cache del \
        binutils \
    && rm -rf /var/cache/apk/*

ARG SSH_HOST_KEY_RSA=""
ARG SSH_HOST_KEY_ECDSA=""
ARG SSH_HOST_KEY_ED25519=""
RUN mkdir -p /var/run/sshd && \
    if [ "${SSH_HOST_KEY_RSA}" != "" ]; then \
        echo "${SSH_HOST_KEY_RSA}" > /etc/ssh/ssh_host_rsa_key; \
        chmod 400 /etc/ssh/ssh_host_rsa_key; \
    else \
        ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa; \
    fi && \
    if [ "${SSH_HOST_KEY_ECDSA}" != "" ]; then \
        echo "${SSH_HOST_KEY_ECDSA}" > /etc/ssh/ssh_host_ecdsa_key; \
        chmod 400 /etc/ssh/ssh_host_ecdsa_key; \
    else \
        ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa; \
    fi && \
    if [ "${SSH_HOST_KEY_ED25519}" != "" ]; then \
        echo "${SSH_HOST_KEY_ED25519}" > /etc/ssh/ssh_host_ed25519_key; \
        chmod 400 /etc/ssh/ssh_host_ed25519_key; \
    else \
        ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519; \
    fi

COPY etc/motd /etc/motd
COPY etc/sshd_config /etc/ssh/sshd_config

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
ARG TIMEZONE="Europe/Warsaw"
RUN ln -snf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime && echo "${TIMEZONE}" > /etc/timezone && \
    addgroup -g 1000 -S bastion && \
    adduser -u 1000 -S sshuser -G bastion -s /bin/sh && \
    echo "root:$(openssl rand -base64 24)" | chpasswd && \
    echo "sshuser:$(openssl rand -base64 24)" | chpasswd

COPY startup.sh startup.sh
COPY route53.json route53.json

CMD ["/startup.sh"]
