FROM docker.io/library/alpine:latest AS base

ARG USER=user
ENV USER=$USER

RUN apk add --no-cache \
      build-base \
      coreutils \
      curl \
      eza \
      findutils \
      fzf \
      git \
      jo \
      jq \
      miller \
      openssh \
      pwgen \
      ripgrep \
      shadow \
      sudo \
      tailscale \
      tree \
      ttyd \
      yadm \
      zsh \
    && groupadd -r sudo \
    && install -d -o root -g root -m 0640 /etc/sudoers.d \
    && (echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-sudo-group.conf) \
    && useradd -m -s $(which zsh) -d /home/${USER} -u 1000 -U -G sudo ${USER} \
    && chown -R ${USER}: /home/${USER} 

RUN export ASDF_DIR=/tmp/asdf \
    && git clone https://github.com/asdf-vm/asdf.git /tmp/asdf \
    && source /tmp/asdf/asdf.sh \
    && asdf plugin add golang \
    && asdf install golang latest \
    && cd /tmp/asdf \
    && asdf local golang latest \
    && make \
    && mv ./asdf /usr/local/bin/asdf \
    && rm -rf /tmp/asdf

# ---

FROM base

ARG DOTFILES_CLASS=container
ARG DOTFILES_REPO
ARG ASDF_PLUGINS="cosign rust golang nodejs lua stylua opentofu bun uv zig neovim zellij bat bitwarden deno github-cli packer"

USER 1000

ENV ASDF_PLUGINS=$ASDF_PLUGINS

WORKDIR /home/${USER}
RUN (echo ${ASDF_PLUGINS} | tr ' ' '\n' | xargs -n1 asdf plugin add) \
    && (echo ${ASDF_PLUGINS} | tr ' ' '\n' | xargs -I{} asdf install {} latest) \
    && (echo ${ASDF_PLUGINS} | tr ' ' '\n' | xargs -I{} asdf set -u {} latest)

ENV DOTFILES_REPO=$DOTFILES_REPO
ENV DOTFILES_CLASS=$DOTFILES_CLASS

RUN --mount=type=ssh,uid=1000 mkdir ~/.ssh \
    && ssh-add -L \
    && (ssh-keyscan -t rsa,ecdsa,ed25519 github.com | tee ~/.ssh/known_hosts) \
    && yadm clone ${DOTFILES_REPO}

RUN yadm config local.class ${DOTFILES_CLASS} \
    && yadm alt

CMD ["/usr/bin/ttyd"]
