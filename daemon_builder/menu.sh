#!/usr/bin/env bash
#####################################################
# Updated by afiniel for crypto use...
#####################################################

FUNC=/etc/functionscoin.sh
if [[ ! -f "$FUNC" ]]; then
	source /etc/functions.sh
else
	source /etc/functionscoin.sh
fi
cd $STORAGE_ROOT/daemon_builder

RESULT=$(dialog --stdout --nocancel --default-item 1 --title "DamonBuilder" --menu "Choose one" -1 60 8 \
' ' "- New and existing Daemon builds and upgrade -" \
1 "Build New Coin Daemon from Source Code" \
2 "Upgrade an Existing Coin Daemon" \
' ' "- NOT WORKING YET. WORK IN PROGRESS If your last coin failed to build try this -" \
3 " WORK IN-PROGRESS! Daemon Build Failed - Help!" \
4 Exit)

if [ $RESULT = ]
then
bash $(basename $0) && exit;
fi

if [ $RESULT = 1 ]
then
clear;
cd $HOME/yiimp_install_script/daemon_builder
source menu2.sh;
fi

if [ $RESULT = 2 ]
then
clear;
cd $HOME/yiimp_install_script/daemon_builder
source menu3.sh;
fi

if [ $RESULT = 3 ]
then
clear;
echo "This is a work in progress. Please try again later. Run this script again to continue with other option!.";
exit;
fi

if [ $RESULT = 4 ]
then
clear;
exit;
fi