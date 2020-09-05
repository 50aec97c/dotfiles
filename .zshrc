autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix

PS1='%F{%(0? 240 %(130? 240 %(127? 196 202)))}─%f '
WORDCHARS=

setopt correctall
setopt globcomplete
setopt histignoredups

bindkey -e
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^I' expand-or-complete-prefix
bindkey '^[[Z' reverse-menu-complete

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ls='ls ${=LS_OPTIONS}'
alias grep='grep --color=auto'

#set_title() {
#  print -Pn "\e]2;$1:q\a"
#}
#
#precmd() {
#  set_title "$PWD"
#}
#
#preexec() {
#  set_title "$1"
#}
