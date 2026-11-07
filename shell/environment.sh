# Move an existing entry to the front. System profiles can put /usr/local/bin
# ahead of an inherited ~/.local/bin, for example in new tmux panes.
path_prepend() {
  [ -d "$1" ] || return 0
  path_prepend_rest=${PATH:-}
  path_prepend_result=$1
  while [ -n "$path_prepend_rest" ]; do
    path_prepend_entry=${path_prepend_rest%%:*}
    case "$path_prepend_rest" in
      *:*) path_prepend_rest=${path_prepend_rest#*:} ;;
      *) path_prepend_rest= ;;
    esac
    [ "$path_prepend_entry" = "$1" ] ||
      path_prepend_result="$path_prepend_result:$path_prepend_entry"
  done
  PATH=$path_prepend_result
  unset path_prepend_entry path_prepend_rest path_prepend_result
}

export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export KREW_ROOT="${KREW_ROOT:-$HOME/.krew}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export VOLTA_HOME="${VOLTA_HOME:-$HOME/.volta}"

path_prepend "$HOME/go/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$KREW_ROOT/bin"
path_prepend "$BUN_INSTALL/bin"
path_prepend "$VOLTA_HOME/bin"
path_prepend "$HOME/.local/bin"

export PATH

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export VISUAL=nvim
elif command -v vim >/dev/null 2>&1; then
  export EDITOR=vim
  export VISUAL=vim
else
  export EDITOR=vi
  export VISUAL=vi
fi
