alias dirs='dirs -v'
if [ -d ${HOME}/.local/share/Trash/files ]
then
    alias rm='mv --backup=numbered --target-directory=${HOME}/.local/share/Trash/files'
fi
