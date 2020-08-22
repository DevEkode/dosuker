FROM ubuntu:20.04

ENV DISPLAY=192.168.1.7:0.0

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        cabextract \
        git \
        gosu \
        gpg-agent \
        p7zip \
        pulseaudio \
        pulseaudio-utils \
        software-properties-common \
        tzdata \
        unzip \
        wget \
        winbind \
        xvfb \
        zenity \
        mesa-utils \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Install newer mesa drivers
RUN add-apt-repository ppa:oibaf/graphics-drivers && \
    apt-get update

# Install screenfetch for debugging
RUN wget https://github.com/KittyKatt/screenFetch/archive/master.zip && \
    unzip master.zip && \
    mv screenFetch-master/screenfetch-dev /usr/bin && \
    cd /usr/bin && \
    mv screenfetch-dev screenfetch && \
    chmod 755 screenfetch

# Install wine
ARG WINE_BRANCH="stable"
RUN wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends winehq-${WINE_BRANCH} \
    && rm -rf /var/lib/apt/lists/*

# Install winetricks
RUN wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/bin/winetricks

COPY download_gecko_and_mono.sh /root/download_gecko_and_mono.sh
RUN chmod +x /root/download_gecko_and_mono.sh \
    && /root/download_gecko_and_mono.sh "$(dpkg -s wine-${WINE_BRANCH} | grep "^Version:\s" | awk '{print $2}' | sed -E 's/~.*$//')"

# Install osu!
RUN WINEPREFIX=~/osu-wine WINEARCH=win32 winetricks -q cjkfonts gdiplus
RUN WINEPREFIX=~/osu-wine WINEARCH=win32 winetricks -q dotnet462