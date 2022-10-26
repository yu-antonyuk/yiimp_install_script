#!/usr/bin/env bash

#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by afiniel for crypto use...
#####################################################

source /etc/functions.sh
source /etc/yiimpoolversion.conf

RESULT=$(dialog --stdout --default-item 1 --title "Yiimpool Installer $YIIMPOOL_VERSION" --menu "Choose one" -1 60 6 \
    ' ' "- User account is ready for use! -" \
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
