set fish_greeting
set -g theme_nerd_fonts yes
set -x PATH $HOME/.pyenv/bin $PATH

# pyenv init
set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PATH $PYENV_ROOT/bin
set -x PATH $PATH $PYENV_ROOT/shims
eval (pyenv init - | source)

# go
set -x GOPATH $HOME/go
set -x PATH $PATH $GOPATH/bin
set GIT_TERMINAL_PROMPT 1
set -x LC_CTYPE en_US.UTF-8
set -x TERM xterm-256color

# downloaded binaries
set -x PATH $PATH $HOME/.local/bin
