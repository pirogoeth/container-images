FROM ubuntu:jammy

ARG MAAS_VERSION=3.5

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y \
        software-properties-common \
        pwgen \
        curl \
        sudo \
        jq \
        bind9-dnsutils \
    && apt-add-repository -y ppa:maas/${MAAS_VERSION} \
    && apt-get update \
    && apt-get install -y maas pwgen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN systemctl disable \
        systemd-timesyncd \
        sshd
RUN systemctl enable \
        named \
        maas-regiond \
        maas-apiserver \
        maas-temporal \
        maas-temporal-worker \
        maas-rackd

RUN mkdir -p /etc/systemd/journald.conf.d
ADD journald.conf.d/* /etc/systemd/journald.conf.d/

WORKDIR /app
ADD . /app
RUN cp /app/maas-setup.service /etc/systemd/system/maas-setup.service \
    && systemctl enable maas-setup

VOLUME ["/etc/maas", "/var/lib/maas"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]