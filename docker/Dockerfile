FROM alpine:3.19.1

WORKDIR /
EXPOSE 22

RUN apk add --no-cache \
    aws-cli \
    curl \
    autossh \
    bind-tools \
    ca-certificates \
    jq \
    openssh \
    openssh-server \
    openssl \
    python3 \
    tzdata && \
    # update dependencies that have known vulnerabilities
    apk add --no-cache --upgrade busybox libcrypto1.1 libretls libssl1.1 ssl_client zlib && \
    # Deactivate short moduli
    awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.tmp && mv /etc/ssh/moduli.tmp /etc/ssh/moduli \
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
