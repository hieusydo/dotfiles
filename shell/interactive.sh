DOTFILES_ROOT=${DOTFILES_ROOT:-"${XDG_CONFIG_HOME:-$HOME/.config}/hdo-dotfiles"}

. "$DOTFILES_ROOT/shell/environment.sh"
. "$DOTFILES_ROOT/shell/aliases.common.sh"

case "$(uname -s)" in
  Darwin) . "$DOTFILES_ROOT/shell/aliases.macos.sh" ;;
  Linux) . "$DOTFILES_ROOT/shell/aliases.linux.sh" ;;
esac

if command -v kubectl >/dev/null 2>&1; then
  . "$DOTFILES_ROOT/shell/aliases.kubernetes.sh"
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

LOCAL_SHELL_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/hdo-dotfiles-local/shell.sh"
if [ -r "$LOCAL_SHELL_CONFIG" ]; then
  . "$LOCAL_SHELL_CONFIG"
fi
