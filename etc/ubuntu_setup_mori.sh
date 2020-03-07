#!/bin/bash
cd `dirname $0`

nvidia_pubkey="http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub"
nvidia_deb="http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.1.168-1_amd64.deb"
cudnn_deb="https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64"
libcudnn="libcudnn7-dev=7.6.4.38-1+cuda10.1"

echo "export PATH=/usr/local/cuda-10.1/bin:${PATH}" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64:${LD_LIBRARY_PATH}" >> ${HOME}/.bashrc
source ${HOME}/.bashrc

#====================================================================
# aptのアップデート
#====================================================================
sudo apt-get update
sudo apt-get upgrade -y

#====================================================================
# 『デスクトップ』『音楽』などの日本語フォルダー名を英語表記にする
#====================================================================
env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update

#====================================================================
# 文字化け対策
#====================================================================
gsettings set org.gnome.gedit.preferences.encodings auto-detected "['UTF-8','CURRENT','SHIFT_JIS','EUC-JP','ISO-2022-JP','UTF-16']"
gsettings set org.gnome.gedit.preferences.encodings shown-in-menu "['UTF-8','SHIFT_JIS','EUC-JP','ISO-2022-JP','UTF-16']"

#====================================================================
# cuda install
#====================================================================
sudo apt-key adv --fetch-keys $nvidia_pubkey
wget $nvidia_deb
yes | sudo dpkg -i "${nvidia_deb##*/}"
sudo apt-get update
sudo apt-get install cuda cuda-drivers


#====================================================================
# cudnn install
#====================================================================
echo "deb $cudnn_deb /" | sudo tee /etc/apt/sources.list.d/nvidia-ml.list
sudo apt-get update
sudo apt-get install $libcudnn

# apt dependence packages
#====================================================================
sudo apt-get install -y git gcc g++ make cmake zip tar curl wget lsb-release fcitx
sudo apt-get install -y build-essential software-properties-common libfontconfig1\
    libbz2-dev libdb-dev libreadline-dev libffi-dev libgdbm-dev liblzma-dev \
    libblas-dev libncursesw5-dev libsqlite3-dev libssl-dev libboost-all-dev \
    zlib1g-dev uuid-dev tk-dev libbz2-dev libeigen3-dev libflann-dev \
    libopencv-dev libpcl-dev libperl-dev libopenni-dev libopenni2-dev \
    libopenmpi-dev libopenexr-dev libopenjp2-7-dev libpng-dev \
    libpython-dev libpython2.7-dev libpython3-dev libpython3.6-dev \
    libqhull-dev mesa-common-dev libglu1-mesa-dev qtcreator qt5-default \
    llvm-8 llvm-8-dev llvm-8-runtime libvtk6-dev libvtk6-qt-dev libx11-dev \
    libtiff-dev libtbb-dev libgtk-3-dev libhdf5-dev libicu-dev libjpeg-dev \
    libdb-dev liblua5.2-dev libtool libtool-bin \
    openssh-server

#====================================================================
# docker install
#====================================================================
yes | sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

yes | sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update 
yes | sudo apt-get install docker-ce docker-ce-cli containerd.io

# nvidia-docker install 
curl -sL https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -sL https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install nvidia-docker2 -y
sudo gpasswd -a $USER docker

#====================================================================
# snap install
#====================================================================
sudo apt-get install -y snapd
yes | sudo snap install snap-store 

#====================================================================
# Ubuntu Web Apps(Gmail/Amazon/Twitter/Facebook)削除
#====================================================================
sudo apt-get remove -y unity-webapps-common xul-ext-unity xul-ext-websites-integration

#====================================================================
# Tex install
#====================================================================
sudo apt-get install -y texlive-full texlive-lang-cjk xdvik-ja texlive-fonts-recommended texlive-fonts-extra

#====================================================================
# ソフトウェアインストール
#====================================================================
# 便利ツール
sudo apt-get install -y tree curl eog evince nkf
sudo apt-get install -y vim xsel

#====================================================================
# Python開発環境構築
#====================================================================
# pyenv 
git clone git://github.com/yyuu/pyenv.git $HOME/.pyenv 
echo "export PATH=$HOME/.pyenv/bin:$PATH" >> $HOME/.bashrc
echo 'eval "$(pyenv init -)"' >> $HOME/.bashrc
source $HOME/.bashrc
pyenv install anaconda3-2019.03
pyenv global anaconda3-2019.03

#====================================================================
# pipで入れれる便利ツール
#====================================================================
# trash-cli : http://tukaikta.blog135.fc2.com/blog-entry-214.html
pip install fzy unar

#==================================================================== 
# SauceCodePro font install
#====================================================================
mkdir ~/.fonts 
wget -O ~/Downloads/SourceCodePro.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/SourceCodePro.zip 
unzip ~/Downloads/SourceCodePro.zip -d ~/.fonts/SourceCodePro 
fc-cache -fv
UUID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${UUID}/ font "SauceCodePro NF Medium 12"
