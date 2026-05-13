# ghost-box

A boilerplate repo for running [Claude Code](https://docs.claude.com/en/docs/claude-code) in a project-scoped Docker container. Works as both a plain `docker compose` setup and a VS Code / JetBrains Dev Container.

## What's in the image

- `@anthropic-ai/claude-code` (the `claude` CLI)
- `node` 24 (base image)
- `python3` + `uv`
- `git`, `ripgrep`, `less`, `curl`, `ca-certificates`
- `make`, `shellcheck`
- `build-essential` (so MCP servers with native deps compile cleanly)

## Prerequisites

- Docker Desktop, OrbStack, Colima, or another Docker-compatible engine
- `docker compose` (bundled with Docker Desktop / OrbStack)

## Quick start

```bash
git clone <this-repo-url> my-project
cd my-project
./bin/ghost-box
```

On first run, `docker compose` builds the image (takes a minute or two). Subsequent runs are instant.

The first time `claude` starts inside the container, it will prompt you to log in. Your credentials live in the `ghost-box-home` named volume and persist across runs and rebuilds.

## Usage

### Run Claude (default)

```bash
./bin/ghost-box
```

### Drop into a shell instead

```bash
./bin/ghost-box bash
```

You'll get an interactive shell at `/workspace`. `claude` is on `$PATH` if you want to launch it manually. `exit` leaves the container; the named volume keeps your shell history and `~/.claude` across sessions.

### Run a one-off command

```bash
./bin/ghost-box bash -c "uv pip install requests && python3 script.py"
```

### Shorter command (optional)

If typing `./bin/ghost-box` gets old, add a shell alias scoped to your project. For example, in `~/.zshrc`:

```bash
alias gb="$HOME/path/to/my-project/bin/ghost-box"
```

Project-scoped helpers like [direnv](https://direnv.net/) (`PATH_add bin`) can put `bin/` on `$PATH` automatically when you `cd` into the project — useful if you work across several boxes.

### Use with VS Code / JetBrains Dev Containers

Open the folder and let the IDE pick up `.devcontainer/devcontainer.json`. The same Dockerfile is reused, and the same `ghost-box-home` volume holds your config.

## Renaming the project

You probably don't want every clone to be called `ghost-box`. There's an optional `rename.sh` that updates all references in one go:

```bash
./rename.sh                # uses the current folder name
./rename.sh my-thing       # or pick an explicit name
```

It updates `Dockerfile`, `compose.yaml`, `.devcontainer/devcontainer.json`, this README, and renames `bin/ghost-box`. After it runs, also rename the folder itself (it tells you the exact command).

## Making it your own repo

To detach from this template and start fresh on GitHub:

```bash
rm -rf .git
git init
git add .
git commit -m "Initial commit from ghost-box template"
gh repo create my-thing --private --source=. --push    # or do this via the GitHub UI
```

## Notes

- **First build is slow, later runs are instant.** The image is cached; `docker compose run --rm` only creates a fresh container each time.
- **Persistence model.** Anything inside `/workspace` is your project on disk (bind mount). Anything inside `/home/node` — config, history, `~/.claude/` — lives in the `ghost-box-home` named volume. The container itself is ephemeral.
- **macOS / Windows bind-mount performance.** `/workspace` is a bind mount across the Docker Desktop VM boundary. Fine for editing; noticeable for very heavy I/O.
- **No `direnv` required.** This repo doesn't ship a `.envrc` — call the wrapper directly with `./bin/ghost-box`.
