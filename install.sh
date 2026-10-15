#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
STATE_HOME=${XDG_STATE_HOME:-"$HOME/.local/state"}
DOTFILES_LINK="$CONFIG_HOME/hdo-dotfiles"
BACKUP_ROOT="$STATE_HOME/hdo-dotfiles/backups"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
LOCK_FILE=${DOTFILES_FRAMEWORK_LOCK:-"$SCRIPT_DIR/frameworks.lock"}

TARGET_SHELL=auto
INSTALL_FRAMEWORKS=0
INSTALL_NVIM=1
DRY_RUN=0
BACKUP_USED=0
TEMP_DIR=

info() {
  printf '%s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

trap cleanup EXIT HUP INT TERM

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --shell auto|bash|zsh|both  Shell configuration to install (default: auto)
  --with-framework           Install the pinned Oh My Bash/Zsh framework
  --no-nvim                  Do not link the Neovim configuration
  --dry-run                  Print planned actions without changing files
  -h, --help                 Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --shell)
      [ "$#" -ge 2 ] || die "--shell requires a value"
      TARGET_SHELL=$2
      shift 2
      ;;
    --with-framework)
      INSTALL_FRAMEWORKS=1
      shift
      ;;
    --no-nvim)
      INSTALL_NVIM=0
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

case "$TARGET_SHELL" in
  auto)
    TARGET_SHELL=${SHELL##*/}
    case "$TARGET_SHELL" in
      bash|zsh) ;;
      *) die "could not detect Bash or Zsh from SHELL=${SHELL:-unset}; use --shell" ;;
    esac
    ;;
  bash|zsh|both) ;;
  *) die "unsupported shell '$TARGET_SHELL'; expected auto, bash, zsh, or both" ;;
esac

[ -r "$LOCK_FILE" ] || die "framework lock file not found: $LOCK_FILE"
. "$LOCK_FILE"

validate_commit() {
  label=$1
  commit=$2

  [ "${#commit}" -eq 40 ] || die "$label commit must be a full 40-character SHA"
  case "$commit" in
    *[!0-9a-f]*) die "$label commit contains non-hexadecimal characters" ;;
  esac
}

validate_commit "Oh My Bash" "$OH_MY_BASH_COMMIT"
validate_commit "Oh My Zsh" "$OH_MY_ZSH_COMMIT"

if [ "${DOTFILES_TEST_MODE:-0}" != 1 ]; then
  [ "$OH_MY_BASH_REPOSITORY" = "https://github.com/ohmybash/oh-my-bash.git" ] ||
    die "Oh My Bash repository is not the expected official source"
  [ "$OH_MY_ZSH_REPOSITORY" = "https://github.com/ohmyzsh/ohmyzsh.git" ] ||
    die "Oh My Zsh repository is not the expected official source"
fi

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

if [ "$DRY_RUN" -eq 0 ]; then
  require_command git
  case "$TARGET_SHELL" in
    bash|both) require_command bash ;;
  esac
  case "$TARGET_SHELL" in
    zsh|both) require_command zsh ;;
  esac
fi

backup_existing() {
  target=$1
  name=$(basename "$target")
  destination="$BACKUP_DIR/$name"
  suffix=1

  while [ -e "$destination" ] || [ -L "$destination" ]; do
    destination="$BACKUP_DIR/$name.$suffix"
    suffix=$((suffix + 1))
  done

  mkdir -p "$BACKUP_DIR"
  mv "$target" "$destination"
  BACKUP_USED=1
  info "Backed up $target to $destination"
}

link_path() {
  source_path=$1
  target_path=$2

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    info "Already linked: $target_path"
    return
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    info "Would link $target_path -> $source_path"
    return
  fi

  mkdir -p "$(dirname "$target_path")"
  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup_existing "$target_path"
  fi
  ln -s "$source_path" "$target_path"
  info "Linked $target_path -> $source_path"
}

install_pinned_repository() {
  label=$1
  repository=$2
  commit=$3
  destination=$4

  if [ "$DRY_RUN" -eq 1 ]; then
    info "Would install $label at $commit from $repository into $destination"
    return
  fi

  if [ -d "$destination/.git" ]; then
    current_repository=$(git -C "$destination" remote get-url origin 2>/dev/null || true)
    [ "$current_repository" = "$repository" ] ||
      die "$destination uses unexpected origin '$current_repository'"
    [ -z "$(git -C "$destination" status --porcelain)" ] ||
      die "$destination has local changes; preserve or remove them before rerunning"

    current_commit=$(git -C "$destination" rev-parse HEAD)
    if [ "$current_commit" != "$commit" ]; then
      git -C "$destination" fetch --quiet --depth 1 origin "$commit"
      git -C "$destination" -c advice.detachedHead=false checkout --quiet --detach "$commit"
    fi
  elif [ -e "$destination" ] || [ -L "$destination" ]; then
    die "$destination exists but is not a Git checkout"
  else
    mkdir -p "$(dirname "$destination")"
    TEMP_DIR="$destination.tmp.$$"
    [ ! -e "$TEMP_DIR" ] || die "temporary path already exists: $TEMP_DIR"

    git clone --quiet --no-checkout "$repository" "$TEMP_DIR"
    git -C "$TEMP_DIR" fetch --quiet --depth 1 origin "$commit"
    git -C "$TEMP_DIR" -c advice.detachedHead=false checkout --quiet --detach "$commit"
    mv "$TEMP_DIR" "$destination"
    TEMP_DIR=
  fi

  installed_commit=$(git -C "$destination" rev-parse HEAD)
  [ "$installed_commit" = "$commit" ] ||
    die "$label verification failed: expected $commit, found $installed_commit"
  info "Installed $label at $commit"
}

link_bash_configuration() {
  link_path "$DOTFILES_LINK/shell/bashrc" "$HOME/.bashrc"
  link_path "$DOTFILES_LINK/shell/bash_profile" "$HOME/.bash_profile"
}

link_zsh_configuration() {
  link_path "$DOTFILES_LINK/shell/zshrc" "$HOME/.zshrc"
  link_path "$DOTFILES_LINK/shell/zprofile" "$HOME/.zprofile"
}

if [ "$INSTALL_FRAMEWORKS" -eq 1 ]; then
  case "$TARGET_SHELL" in
    bash|both)
      install_pinned_repository \
        "Oh My Bash" \
        "$OH_MY_BASH_REPOSITORY" \
        "$OH_MY_BASH_COMMIT" \
        "$HOME/.oh-my-bash"
      ;;
  esac
  case "$TARGET_SHELL" in
    zsh|both)
      install_pinned_repository \
        "Oh My Zsh" \
        "$OH_MY_ZSH_REPOSITORY" \
        "$OH_MY_ZSH_COMMIT" \
        "$HOME/.oh-my-zsh"
      ;;
  esac
fi

link_path "$SCRIPT_DIR" "$DOTFILES_LINK"

if [ "$INSTALL_NVIM" -eq 1 ]; then
  link_path "$DOTFILES_LINK/nvim" "$CONFIG_HOME/nvim"
fi

case "$TARGET_SHELL" in
  bash) link_bash_configuration ;;
  zsh) link_zsh_configuration ;;
  both)
    link_bash_configuration
    link_zsh_configuration
    ;;
esac

if [ "$DRY_RUN" -eq 1 ]; then
  info "Dry run complete; no files were changed."
else
  if [ "$BACKUP_USED" -eq 1 ]; then
    info "Backups: $BACKUP_DIR"
  fi
  info "Installation complete for: $TARGET_SHELL"
  info "Start a fresh login shell to load the configuration."
fi
