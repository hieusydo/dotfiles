# dotfiles

Portable Bash, Zsh, and Neovim configuration for macOS and Linux.

## Safety model

- Shell frameworks are cloned from their official repositories at exact commits
  from `frameworks.lock` only when `--with-framework` is provided.
- The installer does not execute upstream installer scripts.
- Existing configuration is moved into timestamped backups before symlinking.
- Neovim plugins are not downloaded automatically. Review `THIRD_PARTY.md`
  through your organization's approved-source process before installing them.
  LinkedIn users must follow `go/ai-dev-safely`.
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
--dry-run
```

The installer manages:

- Bash: `~/.bashrc`, `~/.bash_profile`, and optionally pinned Oh My Bash
- Zsh: `~/.zshrc`, `~/.zprofile`, and optionally pinned Oh My Zsh
- Neovim: `${XDG_CONFIG_HOME:-~/.config}/nvim`
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

The exported Neovim configuration starts without network access or plugin
execution. After every source in `THIRD_PARTY.md` is approved, install lazy.nvim
at the commit in `nvim/lazy-lock.json`, restore the remaining pinned plugins,
and set `HDO_ENABLE_NVIM_PLUGINS=1` in the machine-local shell configuration.
Neovim refuses to load installed plugins whose Git commits differ from the
lockfile, and it does not install missing plugins during startup. Do not replace
this flow with a curl-pipe-shell installer.

## Validation

```sh
./tests/smoke.sh
```

The smoke test creates local fake framework repositories and isolated home
directories. It does not download or execute third-party framework code.
