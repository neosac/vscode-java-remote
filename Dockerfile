FROM harshavardhanj/openssh:debian

ENV DEBIAN_FRONTEND noninteractive

# SW Base para las demás intalaciones
RUN apt-get update && \
    apt-get -y install build-essential \
                       curl \
                       git \
                       gpg \
                       python \
                       wget \
                       xz-utils \
                       sudo \
                       gnupg \
                       software-properties-common \
    && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Docker CLI y Docker Compose
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && apt-get update && apt-get --assume-yes install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    && add-apt-repository  "deb [arch=arm64] https://download.docker.com/linux/debian \
    $(cat /etc/os-release | grep VERSION_CODENAME | sed -E 's/VERSION_CODENAME=(.+)/\1/g') stable"
RUN apt-get update && apt-get --assume-yes install docker-ce-cli \
    && curl --silent "https://github.com/linuxserver/docker-docker-compose/releases/latest" | \
    grep 'tag/' | \
    sed -E 's/.*tag\/([^"]+)".*/\1/' | \
    xargs -I {} curl -sL "https://github.com/linuxserver/docker-docker-compose/releases/download/"{}'/docker-compose-arm64' \
    -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

# Java
# El mkdir es por un Bug documentado en: https://github.com/geerlingguy/ansible-role-java/issues/64 al tratar de instalar jdk11 en debian 9
RUN mkdir /usr/share/man/man1/
RUN add-apt-repository "deb [arch=arm64] http://ftp.debian.org/debian \
    stretch-backports main" \
    && apt-get update && apt-get -y install openjdk-11-jdk maven gradle

# Node, Yarn, npm y expo-cli (react native)
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo bash - \
    && apt-get install -y nodejs gcc g++ make \
    && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
    && sudo apt-get update && sudo apt-get install yarn \
    && npm install -g expo-cli
