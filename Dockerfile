# syntax=docker/dockerfile:1

FROM container-registry.oracle.com/graalvm/native-image:17
ARG TARGETPLATFORM

RUN apt-get update && apt-get install -y curl jq unzip

ENV RCON_CLI_VERSION="1.6.9"
ENV GITHUB_REPO="itzg/rcon-cli"
ENV BINARY_NAME="rcon-cli"

# Download the correct rcon-cli binary depending on architecture
RUN case "$TARGETPLATFORM" in \
      "linux/amd64") PLATFORM="linux_amd64" ;; \
      "linux/arm64") PLATFORM="linux_arm64" ;; \
      "linux/arm/v7") PLATFORM="linux_armv7" ;; \
      "linux/arm/v6") PLATFORM="linux_armv6" ;; \
      "linux/386") PLATFORM="linux_386" ;; \
      *) echo "Unsupported platform: $TARGETPLATFORM" && exit 0 ;; \
    esac && \
    echo "Detected platform: $PLATFORM" && \
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/$GITHUB_REPO/releases/tags/$RCON_CLI_VERSION | \
    jq -r '.assets[] | select(.name | endswith($PLATFORM + ".tar.gz")) | .browser_download_url') && \
    echo "Downloading $BINARY_NAME for $PLATFORM from $DOWNLOAD_URL" && \
    curl -L $DOWNLOAD_URL -o /tmp/rcon-cli.tar.gz && \
    tar -xz /tmp/rcon-cli.tar.gz \
    mv /tmp/$BINARY_NAME /usr/local/bin && \
    chmod +x /usr/local/bin/$BINARY_NAME && \
    rm /tmp/rcon-cli.tar.gz;

WORKDIR /data
# Newer client packs do not contain heph and vinery, but versions are the same as in 2.0.4 so the 2 archived mods are taken from there
# Avoid overwriting server.properties of existing server. This file will be re-created anyway if missing
RUN curl -fsSL -o "/tmp/server_pack.zip" "https://www.curseforge.com/api/v1/mods/681792/files/5817679/download" && \
    curl -fsSL -o "/tmp/client_pack.zip" "https://www.curseforge.com/api/v1/mods/681792/files/4496671/download" && \
    curl -fsSL -o "/tmp/Log4jPatcher.jar https://github.com/CreeperHost/Log4jPatcher/releases/download/v1.0.1/Log4jPatcher-1.0.1.jar" && \
    unzip -qq /tmp/server_pack.zip -d /tmp/server_pack/ && \
    unzip -qq /tmp/client_pack.zip -d /tmp/client_pack/ && \
    rm /tmp/server_pack/server.properties && \
    mv /tmp/server_pack/ . && \
    cp /tmp/client_pack/mods/vinery-1.1.4.jar mods/ && \
    cp /tmp/client_pack/mods/Hephaestus-1.18.2-3.5.2.155.jar mods/ && \
    mv /tmp/Log4jPatcher.jar . && \
    curl -fsSL -o "server.jar" "https://meta.fabricmc.net/v2/versions/loader/1.18.2/0.16.3/0.11.1/server/jar" && \
    rm -rf /tmp/{server_pack, client_pack, server_pack.zip, client_pack.zip}

