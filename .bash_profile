# set path 
PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH"
export PATTH

# coloring ls 
export CLICOLOR=1;
export LSCOLORS=exfxcxdxbxegedabagacad;

# enable powerline
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh