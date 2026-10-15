#!/bin/sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/hdo-dotfiles-test.XXXXXX")

cleanup() {
  rm -rf "$TMP_ROOT"
}

trap cleanup EXIT HUP INT TERM

create_framework_fixture() {
  repository=$1
  entrypoint=$2
  marker=$3

  mkdir -p "$repository"
  git -C "$repository" init --quiet
  printf 'export HDO_TEST_FRAMEWORK=%s\n' "$marker" > "$repository/$entrypoint"
  git -C "$repository" add "$entrypoint"
  git -C "$repository" \
    -c user.name='Dotfiles Test' \
    -c user.email='dotfiles-test@example.com' \
    commit --quiet -m 'Add framework fixture'
  git -C "$repository" rev-parse HEAD
}

OMB_REPOSITORY="$TMP_ROOT/oh-my-bash"
OMZ_REPOSITORY="$TMP_ROOT/oh-my-zsh"
OMB_COMMIT=$(create_framework_fixture "$OMB_REPOSITORY" oh-my-bash.sh oh-my-bash)
OMZ_COMMIT=$(create_framework_fixture "$OMZ_REPOSITORY" oh-my-zsh.sh oh-my-zsh)
LOCK_FILE="$TMP_ROOT/frameworks.lock"

cat > "$LOCK_FILE" <<EOF
OH_MY_BASH_REPOSITORY='$OMB_REPOSITORY'
OH_MY_BASH_COMMIT='$OMB_COMMIT'
OH_MY_ZSH_REPOSITORY='$OMZ_REPOSITORY'
OH_MY_ZSH_COMMIT='$OMZ_COMMIT'
EOF

run_case() {
  shell_name=$1
  home="$TMP_ROOT/home-$shell_name"
  config="$home/config"
  state="$home/state"
  data="$home/data"
  rc_file=".$shell_name""rc"

  mkdir -p "$home"
  printf 'legacy config\n' > "$home/$rc_file"

  HOME="$home" \
    XDG_CONFIG_HOME="$config" \
    XDG_STATE_HOME="$state" \
    XDG_DATA_HOME="$data" \
    SHELL="$(command -v "$shell_name")" \
    DOTFILES_TEST_MODE=1 \
    DOTFILES_FRAMEWORK_LOCK="$LOCK_FILE" \
    "$shell_name" "$ROOT/install.sh" --shell "$shell_name" --with-framework

  [ -L "$home/$rc_file" ]
  [ -L "$config/hdo-dotfiles" ]
  [ -L "$config/nvim" ]

  case "$shell_name" in
    bash)
      [ "$(git -C "$home/.oh-my-bash" rev-parse HEAD)" = "$OMB_COMMIT" ]
      output=$(
        HOME="$home" \
          XDG_CONFIG_HOME="$config" \
          XDG_STATE_HOME="$state" \
          XDG_DATA_HOME="$data" \
          bash --noprofile --rcfile "$home/.bashrc" -ic 'printf "%s" "$HDO_TEST_FRAMEWORK"' \
          2>/dev/null
      )
      [ "$output" = "oh-my-bash" ]
      ;;
    zsh)
      [ "$(git -C "$home/.oh-my-zsh" rev-parse HEAD)" = "$OMZ_COMMIT" ]
      output=$(
        HOME="$home" \
          ZDOTDIR="$home" \
          XDG_CONFIG_HOME="$config" \
          XDG_STATE_HOME="$state" \
          XDG_DATA_HOME="$data" \
          zsh -d -i -c 'printf "%s" "$HDO_TEST_FRAMEWORK"' \
          2>/dev/null
      )
      [ "$output" = "oh-my-zsh" ]
      ;;
  esac

  find "$state/hdo-dotfiles/backups" -type f -name "$rc_file" | grep -q .
  backup_count=$(find "$state/hdo-dotfiles/backups" -type f | wc -l | tr -d ' ')

  HOME="$home" \
    XDG_CONFIG_HOME="$config" \
    XDG_STATE_HOME="$state" \
    XDG_DATA_HOME="$data" \
    SHELL="$(command -v "$shell_name")" \
    DOTFILES_TEST_MODE=1 \
    DOTFILES_FRAMEWORK_LOCK="$LOCK_FILE" \
    "$shell_name" "$ROOT/install.sh" --shell "$shell_name" --with-framework >/dev/null

  second_backup_count=$(find "$state/hdo-dotfiles/backups" -type f | wc -l | tr -d ' ')
  [ "$backup_count" = "$second_backup_count" ]
}

run_case bash
run_case zsh

failure_home="$TMP_ROOT/home-failure"
failure_lock="$TMP_ROOT/frameworks-failure.lock"
mkdir -p "$failure_home"
printf 'legacy config\n' > "$failure_home/.bashrc"
cat > "$failure_lock" <<EOF
OH_MY_BASH_REPOSITORY='$OMB_REPOSITORY'
OH_MY_BASH_COMMIT='0000000000000000000000000000000000000000'
OH_MY_ZSH_REPOSITORY='$OMZ_REPOSITORY'
OH_MY_ZSH_COMMIT='$OMZ_COMMIT'
EOF

if HOME="$failure_home" \
  XDG_CONFIG_HOME="$failure_home/config" \
  XDG_STATE_HOME="$failure_home/state" \
  XDG_DATA_HOME="$failure_home/data" \
  SHELL="$(command -v bash)" \
  DOTFILES_TEST_MODE=1 \
  DOTFILES_FRAMEWORK_LOCK="$failure_lock" \
  bash "$ROOT/install.sh" --shell bash --with-framework >/dev/null 2>&1; then
  printf 'Expected framework installation failure.\n' >&2
  exit 1
fi

grep -q '^legacy config$' "$failure_home/.bashrc"
[ ! -e "$failure_home/config/hdo-dotfiles" ]

default_home="$TMP_ROOT/home-default"
mkdir -p "$default_home"
default_output=$(
  HOME="$default_home" \
    XDG_CONFIG_HOME="$default_home/config" \
    XDG_STATE_HOME="$default_home/state" \
    XDG_DATA_HOME="$default_home/data" \
    SHELL="$(command -v bash)" \
    bash "$ROOT/install.sh" --shell bash --dry-run
)

if printf '%s\n' "$default_output" | grep -q '^Would install '; then
  printf 'Default installation must not fetch third-party frameworks.\n' >&2
  exit 1
fi

unapproved_lock="$TMP_ROOT/frameworks-unapproved.lock"
unapproved_output="$TMP_ROOT/frameworks-unapproved.out"
cat > "$unapproved_lock" <<EOF
OH_MY_BASH_REPOSITORY='https://example.com/unapproved/oh-my-bash.git'
OH_MY_BASH_COMMIT='$OMB_COMMIT'
OH_MY_ZSH_REPOSITORY='https://github.com/ohmyzsh/ohmyzsh.git'
OH_MY_ZSH_COMMIT='$OMZ_COMMIT'
EOF

if HOME="$default_home" \
  XDG_CONFIG_HOME="$default_home/config" \
  XDG_STATE_HOME="$default_home/state" \
  XDG_DATA_HOME="$default_home/data" \
  SHELL="$(command -v bash)" \
  DOTFILES_FRAMEWORK_LOCK="$unapproved_lock" \
  bash "$ROOT/install.sh" --shell bash --with-framework --dry-run >"$unapproved_output" 2>&1; then
  printf 'Expected unapproved framework source rejection.\n' >&2
  exit 1
fi
grep -q 'Oh My Bash repository is not the expected official source' "$unapproved_output"

SHELL="$(command -v zsh)" "$ROOT/install.sh" --shell both --dry-run >/dev/null

if command -v nvim >/dev/null 2>&1; then
  nvim_home="$TMP_ROOT/home-nvim"
  nvim_config="$nvim_home/config"
  nvim_data="$nvim_home/data"
  nvim_state="$nvim_home/state"
  mkdir -p "$nvim_home" "$nvim_config" "$nvim_data" "$nvim_state"
  ln -s "$ROOT/nvim" "$nvim_config/nvim"

  nvim_output=$(
    HOME="$nvim_home" \
      XDG_CONFIG_HOME="$nvim_config" \
      XDG_DATA_HOME="$nvim_data" \
      XDG_STATE_HOME="$nvim_state" \
      nvim --headless '+qa' 2>&1
  )

  [ ! -e "$nvim_data/nvim/lazy" ]
  printf '%s\n' "$nvim_output" | grep -q 'Neovim plugins are disabled'
fi

printf 'Shell installer smoke tests passed.\n'
