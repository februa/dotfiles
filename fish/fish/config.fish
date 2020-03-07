set fish_greeting

set -g theme_nerd_fonts yes

set XIM fcitx
set XIM fcitx
set XIM_PROGRAM /usr/bin/fcitx
set XIM_ARGS ""
set GTK_IM_MODULE fcitx
set QT_IM_MODULE fcitx
# environment path
set -x PATH /usr/local/cuda-10.2/bin $PATH
set -x PATH /home/leberac/.pyenv/bin $PATH
set -x LD_LIBRARY_PATH /usr/local/cuda-10.2/lib64 $LD_LIBRARY_PATH
set -x TORCH_LIBRARIES /home/leberac/lib/libtorch


# pyenv init
eval (pyenv init - | source)

# dircolors $HOME/.dir_colors/dircolors | head -n 1 | sed 's/^LS_COLORS=/set -x LS_COLORS /;s/;$//')

# go
set -x GOPATH $HOME/go
set -x PATH $PATH $GOPATH/bin
set GIT_TERMINAL_PROMPT 1
# set -x NODE_PATH (nvm root -g)
set -x NVM_DIR $HOME/.nvm
set -x LC_CTYPE en_US.UTF-8
set -x TERM xterm-256color

# downloaded binaries
set -x PATH $PATH $HOME/.local/bin

# enhancd
