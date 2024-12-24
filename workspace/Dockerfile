FROM docker.io/library/alpine:latest

ARG USER=user
ARG DOTFILES_CLASS=container
ARG DOTFILES_REPO
ARG ASDF_PLUGINS="rust golang nodejs lua stylua opentofu uv deno"

ENV USER=$USER
ENV DOTFILES_REPO=$DOTFILES_REPO
ENV DOTFILES_CLASS=$DOTFILES_CLASS
ENV ASDF_PLUGINS=$ASDF_PLUGINS

RUN apk add --no-cache \
      bat \
      build-base \
      curl \
      eza \
      findutils \
      fzf \
      git \
      jo \
      jq \
      miller \
      neovim \
      openssh \
      pwgen \
      ripgrep \
      shadow \
      starship \
      tailscale \
      tree \
      ttyd \
      yadm \
      zsh \
    && groupadd -r sudo \
    && install -d -o root -g root -m 0640 /etc/sudoers.d \
    && (echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-sudo-group.conf) \
    && useradd -m -s $(which zsh) -d /home/${USER} -u 1000 -U -G sudo ${USER}

USER 1000
ENV ASDF_DIR=/home/${USER}/.asdf
RUN git clone https://github.com/asdf-vm/asdf.git /home/${USER}/.asdf \
    && source ~/.asdf/asdf.sh \
    && (echo ${ASDF_PLUGINS} | tr ' ' '\n' | xargs -n1 asdf plugin add) \
    && (echo ${ASDF_PLUGINS} | tr ' ' '\n' | xargs -I{} asdf install {} latest) \
    && (echo ${ASDF_PLUGINS} | tr ' ' '\n' | xargs -I{} asdf global {} latest)

RUN --mount=type=ssh,uid=1000 mkdir ~/.ssh \
    && (ssh-keyscan -t rsa,ecdsa,ed25519 github.com | tee ~/.ssh/known_hosts) \
    && yadm clone ${DOTFILES_REPO}

RUN yadm config local.class ${DOTFILES_CLASS} \
    && yadm alt

ENTRYPOINT ["/usr/bin/ttyd"]
