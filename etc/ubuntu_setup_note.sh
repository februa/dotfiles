#!/bin/bash
cd `dirname $0`

#==================================================================== 
# create symboric link
#====================================================================
mkdir -p $HOME/.config
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

# apt dependence packages
#====================================================================
sudo apt-get install -y git gcc g++ make cmake zip tar curl wget lsb-release \
sudo apt-get install -y build-essential software-properties-common libx11-dev \
    libdb-dev liblua5.2-dev openssh-server
sudo apt-get install -y tree curl nkf
sudo apt-get install -y vim xsel

#====================================================================
# fish install
#====================================================================
sudo apt-get install -y fish 
sudo sed -e '$a /usr/local/bin/fish' /etc/shells 
chsh -s /usr/bin/fish
curl -Lo $HOME/.config/fish/functions/fisher.fish --create-dirs git.io/fisher

fisher add oh-my-fish/theme-clearance
fisher add z 
fisher add 0rax/fish-bd 
fisher add gyakovlev/fish-fzy
fisher add oh-my-fish/plugin-balias 

#====================================================================
# go install
#====================================================================
sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt-get update
sudo apt-get install -y golang-go

# ghq 
go get github.com/motemen/ghq

# peco
ghq get https://github.com/peco/peco
ghq look peco 
go install cmd/peco/peco.go

# gotop
go get github.com/cjbassi/gotop

# docui
go get -d github.com/skanehira/docui
cd $GOPATH/src/github.com/skanehira/docui
GO111MODULE=on go install

#====================================================================
# Python開発環境構築
#====================================================================
# pyenv 
git clone git://github.com/yyuu/pyenv.git $HOME/.pyenv 
export PATH="$HOME/.pyenv/bin:$PATH"
eval "(pyenv init -)"
pyenv install 3.7.3 
pyenv global 3.7.3 

pip install fzy unar trash-cli
pip install neovim neovim-remote

#====================================================================
# neovim install 
#====================================================================
ghq get https://github.com/neovim/neovim
ghq look neovim 
make CMAKE_BUILD_TYPE=Release -j8
sudo make install
ghq get https://github.com/februa/dotfiles 
ghq look dotfiles 
git checkout vim-unix 
ln -s `pwd`/nvim $HOME/.config/ 