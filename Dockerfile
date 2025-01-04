FROM debian:12-slim


ENV DEBIAN_FRONTEND "noninteractive"
ENV STEAM_APP_ID "2430930"
ENV HOME "/opt/steam"
ENV STEAM_PATH "/opt/steam/Steam"
ENV ARK_PATH "/opt/steam/ark"
ENV GE_PROTON_VERSION "8-30"
ENV GE_PROTON_URL "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${GE_PROTON_VERSION}/GE-Proton${GE_PROTON_VERSION}.tar.gz"
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH "${STEAM_PATH}"
ENV STEAM_COMPAT_DATA_PATH "${STEAM_PATH}/steamapps/compatdata/${STEAM_APP_ID}"

RUN \
    useradd -m steam \
    && sed -i 's#^Components: .*#Components: main non-free contrib#g' /etc/apt/sources.list.d/debian.sources \
    && echo steam steam/question select "I AGREE" | debconf-set-selections \
    && echo steam steam/license note '' | debconf-set-selections \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        wget \
        locales \
        lib32gcc-s1 \
        procps \
        steamcmd \
        winbind \
        dbus \
        libfreetype6 \
        net-tools \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -f /etc/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && ln -s /usr/games/steamcmd /usr/bin/steamcmd \
    && wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz \
    && tar xzf rcon-0.10.3-amd64_linux.tar.gz \
    && rm -f rcon-0.10.3-amd64_linux.tar.gz \
    && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin \
    && rm -rf ./rcon-0.10.3-amd64_linux \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y \
    && mkdir -p /opt/steam \
    && chown steam:steam /opt/steam

USER steam

RUN mkdir -p "$ARK_PATH" \
    && mkdir -p "${ARK_PATH}/ShooterGame/Saved" \
    && mkdir -p "${STEAM_PATH}/compatibilitytools.d" \
    && mkdir -p "${STEAM_PATH}/steamapps/compatdata/${STEAM_APP_ID}" \
    && mkdir -p "${HOME}/.steam" \
    && steamcmd +quit \
    && ln -s "${HOME}/.local/share/Steam/steamcmd/linux32" "${HOME}/.steam/sdk32" \
    && ln -s "${HOME}/.local/share/Steam/steamcmd/linux64" "${HOME}/.steam/sdk64" \
    && ln -s "${HOME}/.steam/sdk32/steamclient.so" "${HOME}/.steam/sdk32/steamservice.so" \
    && ln -s "${HOME}/.steam/sdk64/steamclient.so" "${HOME}/.steam/sdk64/steamservice.so" \
    && wget "$GE_PROTON_URL" -O "/opt/steam/GE-Proton${GE_PROTON_VERSION}.tgz" \
    && tar -x -C "${STEAM_PATH}/compatibilitytools.d/" -f "/opt/steam/GE-Proton${GE_PROTON_VERSION}.tgz" \
    && rm "/opt/steam/GE-Proton${GE_PROTON_VERSION}.tgz"   
    
ADD entrypoint /opt/steam/entrypoint

WORKDIR /opt/steam

CMD ["/opt/steam/entrypoint"]
