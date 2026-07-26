FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG FLUTTER_CHANNEL=stable

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        clang \
        cmake \
        curl \
        git \
        libglu1-mesa \
        ninja-build \
        unzip \
        xz-utils \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${FLUTTER_CHANNEL}" \
        https://github.com/flutter/flutter.git /opt/flutter \
    && chown -R vscode:vscode /opt/flutter

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

USER vscode

RUN flutter config --enable-web \
    && flutter precache --web \
    && dart --disable-analytics \
    && flutter config --no-analytics

WORKDIR /workspaces/Rumi
