ARG ALPINE_VERSION=3.19
ARG DOCKER_VERSION=v25.0.2
ARG COMPOSE_VERSION=v2.24.5
ARG BUILDX_VERSION=v0.12.1
ARG LOGOLS_VERSION=v1.3.7

# Use some qdm12 binpot images, these will eventually be replaced by my own binpot images
FROM qmcgaw/binpot:docker-${DOCKER_VERSION} AS docker
FROM qmcgaw/binpot:compose-${COMPOSE_VERSION} AS compose
FROM qmcgaw/binpot:buildx-${BUILDX_VERSION} AS buildx

FROM alpine:${ALPINE_VERSION}
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install shadow for usermod
RUN apk add -q --update --progress --no-cache shadow

# Create a non-root user
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

# Install sudo
RUN apk add -q --update --progress --no-cache sudo
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

# CA certificates
RUN apk add -q --update --progress --no-cache ca-certificates

# Timezone
RUN apk add -q --update --progress --no-cache tzdata
ENV TZ=

# Do everything from here as the non-root user
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Copy the start scripts
COPY --chown=${USERNAME}:${USERNAME} ./.start /home/${USERNAME}/.start/
RUN chmod +x /home/${USERNAME}/.start/*.sh
# Copy the start.sh script to the home directory
COPY --chown=${USERNAME}:${USERNAME} .start.sh /home/${USERNAME}/
RUN chmod +x /home/${USERNAME}/.start.sh

# Setup Git and SSH
RUN sudo apk add -q --update --progress --no-cache git mandoc git-doc openssh-client
# One of the start scripts will sort the rest

# Setup Global Git Hooks
COPY --chown=${USERNAME}:${USERNAME} .githooks /home/${USERNAME}/.githooks
RUN chmod +x /home/${USERNAME}/.githooks/*
# One of the start scripts will sort the rest

# Setup shell
ENTRYPOINT [ "/bin/zsh" ]
RUN sudo apk add -q --update --progress --no-cache zsh nano zsh-vcs
ENV EDITOR=nano \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN sudo usermod --shell /bin/zsh ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} shell/.zshrc /home/${USERNAME}/
RUN git clone --single-branch --depth 1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

COPY --chown=${USERNAME}:${USERNAME} shell/.p10k.zsh /home/${USERNAME}/
RUN sudo apk add -q --update --progress --no-cache zsh-theme-powerlevel10k gitstatus && \
    ln -s /usr/share/zsh/plugins/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k

# Start of binpot images
COPY --from=docker --chown=${USERNAME}:${USERNAME} /bin /usr/local/bin/docker
ENV DOCKER_BUILDKIT=1
COPY --from=compose --chown=${USERNAME}:${USERNAME} /bin /usr/libexec/docker/cli-plugins/docker-compose
ENV COMPOSE_DOCKER_CLI_BUILD=1
RUN echo "alias docker-compose='docker compose'" >> /home/${USERNAME}/.zshrc
COPY --from=buildx --chown=${USERNAME}:${USERNAME} /bin /usr/libexec/docker/cli-plugins/docker-buildx
# End of binpot images

# VSCode specific (speed up setup)
RUN sudo apk add -q --update --progress --no-cache libstdc++

# Unintall shaddow for usermod
RUN sudo apk del shadow
