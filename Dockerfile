FROM node:24-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ripgrep \
    less \
    ca-certificates \
    curl \
    python3 \
    make \
    shellcheck \
    build-essential \
    zsh \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin INSTALLER_NO_MODIFY_PATH=1 sh

RUN npm install -g @anthropic-ai/claude-code

# oh-my-zsh installed system-wide so the named home volume can't hide it
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /opt/oh-my-zsh \
    && chmod -R a+rX /opt/oh-my-zsh \
    && mkdir -p /etc/zsh \
    && printf '%s\n' \
        'export ZSH=/opt/oh-my-zsh' \
        'export ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh' \
        'mkdir -p $ZSH_CACHE_DIR' \
        'ZSH_THEME=robbyrussell' \
        'plugins=(git)' \
        'source $ZSH/oh-my-zsh.sh' \
        > /etc/zsh/zshrc

ENV SHELL=/usr/bin/zsh

USER node
WORKDIR /workspace

CMD ["claude"]
