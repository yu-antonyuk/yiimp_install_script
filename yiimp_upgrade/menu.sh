#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by afiniel for crypto use...
#####################################################

source /etc/functions.sh
cd $HOME/yiimp_install_script/yiimp_upgrade

RESULT=$(dialog --stdout --nocancel --default-item 1 --title "Yiimpool YiiMP Updater" --menu "Choose one" -1 65 7 \
' ' "- Upgrade Stratum and YiiMP Single Server Installation -" \
1 "Start YiiMP Updater Installation" \
' ' "- Exit -" \
2 Exit)

if [ $RESULT = 1 ]
then
clear;
cd $HOME/yiimp_install_script/yiimp_upgrade
source single.sh;
fi

if [ $RESULT = 2 ]
then
clear;
exit;
fi
