FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libdb++-dev \
    libboost-all-dev \
    libqrencode-dev \
    libminiupnpc-dev \
    qt5-default \
    qtbase5-dev \
    qtbase5-dev-tools \
    qttools5-dev-tools \
    libqt5opengl5-dev \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY . .

RUN mkdir -p src/obj/crypto

RUN cd src && make -f makefile.unix USE_UPNP=1 STATIC=1

RUN qmake "RELEASE=1" wayawolfcoin.pro && make