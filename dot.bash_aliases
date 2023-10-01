# Enable history
HISTSIZE=1000
HISTFILESIZE=2000

# Enable color support
alias ls='ls --color=auto'
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Enable bash-completion
if [ -n "$BASH_VERSION" ]; then
    if [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# my stuff
alias ed='emacs -nw'

cd ~/work

