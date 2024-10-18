# syntax=docker/dockerfile:1

FROM container-registry.oracle.com/graalvm/native-image:17
ARG TARGETPLATFORM

RUN apt-get update && apt-get install -y curl jq

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
    tar -xzvf /tmp/rcon-cli.tar.gz \
    mv /tmp/$BINARY_NAME /usr/local/bin && \
    chmod +x /usr/local/bin/$BINARY_NAME && \
    rm /tmp/rcon-cli.tar.gz;

