path_prepend() {
  [ -d "$1" ] || return 0
  case ":${PATH:-}:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
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
