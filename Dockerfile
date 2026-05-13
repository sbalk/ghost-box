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
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin INSTALLER_NO_MODIFY_PATH=1 sh

RUN npm install -g @anthropic-ai/claude-code

USER node
WORKDIR /workspace

CMD ["claude"]
