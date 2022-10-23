#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by finiel for yiimpool use...
#####################################################

source /etc/functions.sh

RESULT=$(dialog --stdout --nocancel --default-item 1 --title "Yiimpool Installer v0.4.1" --menu "Choose one" -1 60 16 \
' ' "-  Yiimp  -" \
1 "Start Yiimp Install" \
' ' "- Daemon Wallet Builder -" \
2 "Daemonbuilder" \
3 Exit)
if [ $RESULT = 1 ]
then
clear;
cd $HOME/yiimp_install_script/yiimp_single
source start.sh;
fi

if [ $RESULT = 2 ]
then
clear;
cd $HOME/yiimpool/install
source bootstrap_coin.sh;
fi

if [ $RESULT = 3 ]
then
clear;
exit;
fi
