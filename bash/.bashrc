# Vim for the command line
set -o vi

# PS1 Style
if [ -n "$SSH_CONNECTION" ]; then
  # Remote (SSH) — red hostname
  PS1='\[\e[32m\][\[\e[32m\]\u\[\e[31m\]@\h\[\e[31m\]]\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
else
  # Local
  PS1='\[\e[32m\][\[\e[32m\]\u\[\e[33m\]@\h\[\e[33m\]]\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
fi

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# PATH
export PATH="\
$HOME/.local/bin:\
$HOME/.opencode/bin:\
$HOME/.jbang/bin:\
/home/linuxbrew/.linuxbrew/bin:\
/home/linuxbrew/.linuxbrew/sbin:\
$PATH"

source <(fzf --bash)

# nvm — lazy-loaded. Pre-seed PATH with the default node so node/npm/npx
# are instant; only `nvm` itself triggers sourcing the 4.6k-line nvm.sh.
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR/versions/node" ]; then
    _nvm_default=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
    if [ -z "$_nvm_default" ] || [ ! -d "$NVM_DIR/versions/node/$_nvm_default" ]; then
        _nvm_default=$(ls -1 "$NVM_DIR/versions/node" 2>/dev/null | sort -V | tail -1)
    fi
    [ -n "$_nvm_default" ] && PATH="$NVM_DIR/versions/node/$_nvm_default/bin:$PATH"
    unset _nvm_default
fi

nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
}


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/zayed/.sdkman"
[[ -s "/home/zayed/.sdkman/bin/sdkman-init.sh" ]] && source "/home/zayed/.sdkman/bin/sdkman-init.sh"
