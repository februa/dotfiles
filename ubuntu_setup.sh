#!/bin/bash
#====================================================================
# aptのアップデート
#====================================================================
yes | sudo apt-get update
yes | sudo apt-get upgrade

#====================================================================
# 『デスクトップ』『音楽』などの日本語フォルダー名を英語表記にする
#====================================================================
env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update

#====================================================================
# デスクトップがフリーズした場合に備えて「Ctrl+Alt+Backspace」で強制終了を有効化
#====================================================================
sudo dpkg-reconfigure keyboard-configuration

#====================================================================
# 文字化け対策
#====================================================================
gsettings set org.gnome.gedit.preferences.encodings auto-detected "['UTF-8','CURRENT','SHIFT_JIS','EUC-JP','ISO-2022-JP','UTF-16']"
gsettings set org.gnome.gedit.preferences.encodings shown-in-menu "['UTF-8','SHIFT_JIS','EUC-JP','ISO-2022-JP','UTF-16']"

#====================================================================
# プラグインの追加
#====================================================================
yes | sudo apt-get install gedit-plugins

#====================================================================
# cuda install
#====================================================================
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.1.168-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1804_10.1.168-1_amd64.deb
sudo apt update

sudo apt install cuda cuda-drivers

#====================================================================
# cudnn install
#====================================================================
echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" | sudo tee /etc/apt/sources.list.d/nvidia-ml.list
sudo apt update
sudo apt install libcudnn7-dev=7.5.0.56-1+cuda10.0

#====================================================================
# apt dependence packages
#====================================================================
yes | sudo apt install git gcc g++ clang-8 make cmake zip tar curl wget lsb-release fcitx
yes | sudo apt install build-essential software-properties-common libfontconfig1\
    libbz2-dev libdb-dev libreadline-dev libffi-dev libgdbm-dev liblzma-dev \
    libblas-dev libncursesw5-dev libsqlite3-dev libssl-dev libboost-all-dev \
    zlib1g-dev uuid-dev tk-dev libbz2-dev libeigen3-dev libflann-dev \
    libopencv-dev libpcl-dev libperl-dev libopenni-dev libopenni2-dev \
    libopenmpi-dev libopenexr-dev libopenjp2-7-dev libpng-dev \
    libpython-dev libpython2.7-dev libpython3-dev libpython3.6-dev \
    libqhull-dev mesa-common-dev libglu1-mesa-dev qtcreator qt5-default \
    llvm-8 llvm-8-dev llvm-8-runtime libvtk6-dev libvtk6-qt-dev libx11-dev \
    libtiff-dev libtbb-dev libgtk-3-dev libhdf5-dev libicu-dev libjpeg-dev \
    libdb-dev liblua5.2-dev libtool libtool-bin 
  

#====================================================================
# docker install
#====================================================================
yes | sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update 
yes | sudo apt install docker-ce docker-ce-cli containerd.io

# nvidia-docker install 
curl -sL https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
sudo apt update
yes | sudo apt install nvidia-docker2
sudo gpasswd -a $USER docker
#====================================================================
# snap install
#====================================================================
yes | sudo apt install snapd
yes | sudo snap install --channel=1.10/stable --classic go
yes | sudo snap install code 
yes | sudo snap install remmina
yes | sudo snap install snap-store 
yes | sudo snap install gitkraken


#====================================================================
# go application install 
#====================================================================
go get github.com/motemen/ghq
curl https://glide.sh/get | sh
ghq get https://github.com/peco/peco
ghq look peco 
glide install
go install cmd/peco/peco.go

#====================================================================
# fish install
#====================================================================
yes | sudo apt install fish 
sudo sed -e '$a /usr/local/bin/fish' /etc/shells 
sudo chsh -s /usr/local/bin/fish
curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher

/usr/local/bin/fish
fisher add oh-my-fish/theme-clearance
fisher add z 
fisher add 0rax/fish-bd 
fisher add oh-my-fish/plugin-peco 
fisher add oh-my-fish/plugin-balias 

#====================================================================
# コマンドラインツール
#====================================================================
yes | sudo apt install hub

#====================================================================
# Ubuntu Web Apps(Gmail/Amazon/Twitter/Facebook)削除
#====================================================================
yes | sudo apt-get remove unity-webapps-common xul-ext-unity xul-ext-websites-integration

#====================================================================
# updatedbの無効化(locateコマンド使わないなら絶対しておくべき)
#====================================================================
sudo chmod 644 /etc/cron.daily/mlocate
#もとに戻すならsudo chmod 755 /etc/cron.daily/mlocate

#====================================================================
# Tex install
#====================================================================
sudo apt install texlive-full texlive-lang-cjk xdvik-ja texlive-fonts-recommended texlive-fonts-extra
#====================================================================
# ソフトウェアインストール
#====================================================================
# 便利ツール
yes | sudo apt-get install tree curl eog evince nkf
yes | sudo apt-get install imagemagick pdftk vim xsel
yes | sudo apt-get install flashplugin-installer

# heroku-toolbelt
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

# google chrome 
echo 'google chrome'
sudo sh -c ‘echo “deb http://dl.google.com/linux/chrome/deb/ stable main” >> /etc/apt/sources.list.d/google.list’
sudo wget -q -O – https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt-get install google-chrome-stable

#====================================================================
# Python開発環境構築
#====================================================================
# pyenv 
git clone git://github.com/yyuu/pyenv.git $HOME/.pyenv 
set -x PATH $HOME/.pyenv/bin $PATH
eval (pyenv init - | source)
pyenv install 2.7.16 
pyenv install 3.7.3 
pyenv global 3.7.3 

#====================================================================
# pipで入れれる便利ツール
#====================================================================
# trash-cli : http://tukaikta.blog135.fc2.com/blog-entry-214.html
yes | sudo pip install trash-cli
yes | sudo pip install neovim neovim-remote


#====================================================================
# neovim install 
#====================================================================
ghq get https://github.com/neovim/neovim
ghq look neovim 
make CMAKE_BUILD_TYPE=Release -j8
sudo make install

#====================================================================
# その他
#====================================================================
echo 'その他にインストールするもの'
echo 'dropbox'
echo 'FileZilla'
echo 'slack'