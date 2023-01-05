#!/bin/env bash

#####################################################
# Source code https://github.com/end222/pacmenu     #
# Updated by Afiniel for yiimpool use...            #
#####################################################

source /etc/functions.sh

RESULT=$(dialog --stdout --default-item 1 --title "Yiimpool Yiimp installer v0.7.1" --menu "Choose one" -1 60 6 \
' ' "- Do want to install yiimp with wireguard?  -" \
1 "No" \
2 "Yes" \
3 Exit)
if [ $RESULT = 1 ]
then
clear;
echo '
wireguard=false
' | sudo -E tee $HOME/yiimp_install_script/yiimp_single/.wireguard.install.cnf >/dev/null 2>&1;
fi

if [ $RESULT = 2 ]
then
clear;
echo '
wireguard=true
' | sudo -E tee $HOME/yiimp_install_script/yiimp_single/.wireguard.install.cnf >/dev/null 2>&1;
echo 'server_type='db'
DBInternalIP='10.0.0.2'
' | sudo -E tee $STORAGE_ROOT/yiimp/.wireguard.conf >/dev/null 2>&1;
fi

if [ $RESULT = 3 ]
then
clear;
exit;
fi