FROM docker.io/library/ubuntu:mantic

ARG SDRPP_VERSION=nightly
RUN apt update \
    && apt install -y \
        curl \
        libfftw3-dev \
        libglfw3-dev \
        libvolk-dev \
        librtaudio-dev \
        libzstd-dev \
    && curl -o sdrpp.deb -sSL "https://github.com/AlexandreRouma/SDRPlusPlus/releases/download/$SDRPP_VERSION/sdrpp_ubuntu_mantic_amd64.deb" \
    && dpkg -i sdrpp.deb \
    && rm sdrpp.deb \
    && apt clean

ENTRYPOINT ["/usr/bin/sdrpp"]