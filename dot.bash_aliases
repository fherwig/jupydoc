# Enable history
HISTSIZE=1000
HISTFILESIZE=2000

# Enable color support
alias ls='ls --color=auto'
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# my stuff
alias ed='emacs -nw'

cd ~/work

# if /home/fherwig/work/home does not exist then
# set link from /home/fherwig/home to /home/fherwig/work/home
if [ ! -e /home/fherwig/work/home ]; then
    ln -s /home/fherwig/home /home/fherwig/work/home
fi