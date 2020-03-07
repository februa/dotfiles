#!/bin/bash
cd `dirname $0`

#==================================================================== 
# create symboric link
#====================================================================
mkdir -p $HOME/.config $HOME/.local/bin
conf=(  "../home_config/.bash_aliases" 
        "../home_config/.bash_profile" 
        "../home_config/.bashrc" 
        "../home_config/.gitconfig" 
        "../home_config/.gitignore" 
        "../home_config/.latexmkrc" 
        "../home_config/.tmux" 
        "../home_config/.tmux.conf" 
        "../home_config/.vimrc" 
)
ln -sf `readlink -f ${conf[@]}` $HOME
ln -sf `readlink -f ../nvim` $HOME/.config
ln -sf `readlink -f ../fish` $HOME/.config

source ${HOME}/.bashrc

#====================================================================
# aptのアップデート
#====================================================================
sudo apt-get update
sudo apt-get upgrade -y

# apt dependence packages
#====================================================================
sudo apt-get install -y git gcc g++ make cmake zip tar curl wget lsb-release
sudo apt-get install -y build-essential software-properties-common libx11-dev \
    liblua5.2-dev openssh-server libtool libtool-bin
sudo apt-get install -y tree curl nkf fzy
sudo apt-get install -y vim xsel

# neovim required packages
sudo apt-get install -y ninja-build gettext \
        libtool libtool-bin autoconf automake \
        cmake g++ pkg-config unzip

# python required
sudo apt-get install -y curl llvm sqlite3 libssl-dev \
        libbz2-dev libreadline-dev libsqlite3-dev \
        libncurses5-dev libncursesw5-dev python-tk \
        python3-tk tk-dev aria2 \
        libpython2.7-dev libpython3.7-dev

#====================================================================
# fish install
#====================================================================
if ! type "fish" > /dev/null 2>&1; then
    sudo apt-get install -y fish 
    sudo sed -e '$a /usr/local/bin/fish' /etc/shells 
    chsh -s /usr/bin/fish
    curl -Lo $HOME/.config/fish/functions/fisher.fish --create-dirs git.io/fisher

    if type "fish" > /dev/null 2>&1; then
        fish $HOME/.config/fish/functions/fisher.fish
    fi
fi
#====================================================================
# go install
#====================================================================
if ! type "go" > /dev/null 2>&1; then
    sudo add-apt-repository -y ppa:longsleep/golang-backports
    sudo apt-get update
    sudo apt-get install -y golang-go
fi

# ghq 
if ! type "ghq" > /dev/null 2>&1; then
    go get github.com/motemen/ghq
fi

# peco
if ! type "peco" > /dev/null 2>&1; then
    ghq get https://github.com/peco/peco
    cd `ghq root`/github.com/peco/peco
    go install cmd/peco/peco.go
fi

# gotop
if ! type "gotop" > /dev/null 2>&1; then
    go get github.com/cjbassi/gotop
fi

# docui
if ! type "docui" > /dev/null 2>&1; then
    go get -d github.com/skanehira/docui
    cd $GOPATH/src/github.com/skanehira/docui
    GO111MODULE=on go install
fi

#====================================================================
# Python開発環境構築
#====================================================================
# pyenv 
if ! type "pyenv" > /dev/null 2>&1; then
    git clone git://github.com/yyuu/pyenv.git $HOME/.pyenv 
    export PATH="$HOME/.pyenv/shims:$PATH"
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    pyenv install 3.7.3 
    pyenv global 3.7.3 
fi

#====================================================================
# neovim install 
#====================================================================
if ! type "nvim" > /dev/null 2>&1; then
    pip install trash-cli
    pip install neovim neovim-remote
    ghq get https://github.com/neovim/neovim
    cd `ghq root`/github.com/neovim/neovim
    make CMAKE_BUILD_TYPE=Release -j8
    sudo make install
fi