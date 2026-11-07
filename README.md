# dotfiles

Portable Bash, Zsh, Neovim, and coding agent configuration for macOS and Linux.

## Safety model

- Shell frameworks are cloned from their official repositories at exact commits
  from `frameworks.lock` only when `--with-framework` is provided.
- The installer does not execute upstream installer scripts.
- Existing configuration is moved into timestamped backups before symlinking.
- On first start, Neovim installs lazy.nvim and its plugins at the commits in
  `nvim/lazy-lock.json`. It does not check for plugin updates.
- Histories, credentials, SSH configuration, Kubernetes configuration, and
  machine-local values are not stored here.

## Requirements

Install `git` and the shell you want through an approved system package source.
For the full Neovim experience, also install an approved Neovim build,
`ripgrep`, `fd`, and C build tools for Treesitter.

## Install

```sh
git clone git@github.com:hieusydo/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh --shell auto --dry-run
./install.sh --shell auto
```

`auto` uses the basename of `$SHELL`. Install both variants with:

```sh
./install.sh --shell both
```

After the pinned framework sources in `THIRD_PARTY.md` are approved, install
them explicitly:

```sh
./install.sh --shell auto --with-framework --dry-run
./install.sh --shell auto --with-framework
```

Available options:

```text
--shell auto|bash|zsh|both
--with-framework
--no-nvim
--no-agents
--dry-run
```

The installer manages:

- Bash: `~/.bashrc`, `~/.bash_profile`, and optionally pinned Oh My Bash
- Zsh: `~/.zshrc`, `~/.zprofile`, and optionally pinned Oh My Zsh
- Neovim: `${XDG_CONFIG_HOME:-~/.config}/nvim`
- Copilot CLI: `${COPILOT_HOME:-~/.copilot}/copilot-instructions.md`
- Repository link: `${XDG_CONFIG_HOME:-~/.config}/hdo-dotfiles`

Start a fresh login shell after installation.

## Machine-local configuration

Put hostnames, private paths, work-specific aliases, and identity values in:

```text
${XDG_CONFIG_HOME:-~/.config}/hdo-dotfiles-local/shell.sh
```

Use `shell/local.example.sh` as a starting point. This file is outside the
repository and is sourced by both Bash and Zsh.

## Neovim plugins

Neovim installs its plugins on first start. It clones lazy.nvim at the commit
in `nvim/lazy-lock.json`, and lazy.nvim installs the other plugins at their
commits in the same file. The first start needs `git` and network access. If
the installation fails, Neovim starts without plugins and shows a warning.

lazy.nvim does not check for updates. To update the plugins, run `:Lazy update`,
then commit the changed `nvim/lazy-lock.json`. After you pull a changed
lockfile on another host, run `:Lazy restore`.

To skip the Neovim configuration on a host, run the installer with `--no-nvim`.

## Agent instructions

`agents/AGENTS.md` contains personal rules for coding agents, for example
writing style, the pull request description format, and the Google Docs format.
It uses the [AGENTS.md](https://agents.md) format: plain Markdown with no
required fields.

The installer links the file as the Copilot CLI personal instruction file:

```text
${COPILOT_HOME:-~/.copilot}/copilot-instructions.md -> agents/AGENTS.md
```

Copilot CLI loads this file in every session, in every repository. It combines
the file with the repository instructions, for example `AGENTS.md` and
`.github/copilot-instructions.md`. Copilot CLI does not define a precedence
order between these files, so do not write rules that conflict.

On a remote host, clone this repository and run the installer. To install only
the agent instructions, move any existing `copilot-instructions.md` to a backup
location, then link the file:

```sh
mkdir -p ~/.copilot
ln -s ~/Developer/dotfiles/agents/AGENTS.md ~/.copilot/copilot-instructions.md
```

To verify the setup, run `copilot instruction list`. The output must include
`Home copilot-instructions.md`. In an interactive session, use `/instructions`.
A running session does not reload instruction files. Start a new session after
you change `agents/AGENTS.md`.

Do not put private or work-specific rules in this repository. Put them in
`~/.copilot/instructions/<name>.instructions.md` with `applyTo: "**"` in the
front matter.

Other agents read personal instructions from different locations:

| Agent | Personal instruction file | Setup |
|---|---|---|
| Codex CLI | `~/.codex/AGENTS.md` | Link the file to `agents/AGENTS.md`. |
| Claude Code | `~/.claude/CLAUDE.md` | Add the line `@~/.config/hdo-dotfiles/agents/AGENTS.md`. |

Copilot cloud agent sessions, for example sessions that start with `/delegate`,
run on GitHub. These sessions and Copilot code review do not read personal
instruction files. They read only repository and organization instructions.

## Validation

```sh
./tests/smoke.sh
```

The smoke test creates local fake framework and lazy.nvim repositories and
isolated home directories. It does not download or execute third-party code.
