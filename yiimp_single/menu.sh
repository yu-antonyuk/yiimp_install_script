#!/usr/bin/env bash

#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by afiniel for crypto use...
#####################################################

source /etc/functions.sh

RESULT=$(dialog --stdout --default-item 1 --title "Yiimpool Installer v0.4.1" --menu "Choose one" -1 60 6 \
    ' ' "- Pre-install complete. Do you want to continue with the Yiimp Install? -" \
    1 "Continue" \
    2 Exit)
if [ $RESULT = 1 ]; then
    clear
    echo '
wireguard=false
' | sudo -E tee $HOME/yiimp_install_script/yiimp_single/.wireguard.install.cnf >/dev/null 2>&1
fi

if [ $RESULT = 2 ]; then
    clear
    exit
fi
