alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'
alias ~='cd ~'
alias e='exit'

# bat aliases
alias cat='batcat' # batcat is the name of the binary on debian
man() {
  command man "$@" | batcat -l man -p
}

# apt aliases
alias q='apt search'
alias i='sudo apt install -y'
alias u='sudo apt update && sudo apt upgrade -y && brew update && brew upgrade && flatpak update -y'

# Flatpak aliases
alias fp='flatpak'
alias fpq='flatpak search'
alias fpi='flatpak install'
alias code='flatpak run com.visualstudio.code'

# Tools
alias lg='lazygit'
alias ld='lazydocker'
alias z='zellij'
alias jb='jbang'
alias fd='fdfind'
alias ff='fastfetch'
alias cc='claude --dangerously-skip-permissions'
alias ccr='claude --resume'
alias ccu='claude update'
alias oc='opencode'

# Yazi - cd to directory on exit
y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
