alias cd..='cd ..'
alias ..='cd ..'
alias .1='cd ..'
alias ...='cd ../..'
alias .2='cd ../..'
alias ....='cd ../../..'
alias .3='cd ../../..'
alias .....='cd ../../../..'
alias .4='cd ../../../..'

case "$(uname -s)" in
  Darwin)
    alias ls='ls -laGh'
    if command -v gls >/dev/null 2>&1; then
      alias ll='gls --color=auto -Flh --group-directories-first'
    else
      alias ll='ls -laGh'
    fi
    ;;
  *)
    alias ls='ls -la --color=auto -h'
    alias ll='ls --color=auto -Flh --group-directories-first'
    ;;
esac

alias df='df -H'
alias du='du -ch'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias bc='bc -l'
alias mkdir='mkdir -pv'

if command -v colordiff >/dev/null 2>&1; then
  alias diff='colordiff'
fi

if command -v nvim >/dev/null 2>&1; then
  alias vi='nvim'
fi
