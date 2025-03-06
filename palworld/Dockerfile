ARG STEAMCMD_VERSION=${STEAMCMD_VERSION:-latest}

FROM docker.io/steamcmd/steamcmd:${STEAMCMD_VERSION}

RUN apt update \
    && apt dist-upgrade -y \
      net-tools+ \
      telnet+ \
    && useradd -d /game -r game

USER game

ENV USER=game
ENV HOME=/game

WORKDIR /game

RUN steamcmd \
    +force_install_dir /game \
    +login anonymous \
    +app_update 2394010 validate \
    +quit

ENTRYPOINT ["bash", "/game/PalServer.sh"]
# game server port
EXPOSE 8211/udp
# game REST API port
EXPOSE 8212/tcp
# RCON port
EXPOSE 25575/tcp
