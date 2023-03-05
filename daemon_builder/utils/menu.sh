#!/usr/bin/env bash
#####################################################
# Updated by Afiniel
#####################################################

source /etc/daemonbuilder.sh
source $STORAGE_ROOT/daemon_builder/conf/info.sh

cd $STORAGE_ROOT/daemon_builder

#LATESTVER=$(curl -sL 'https://api.github.com/repos/Afiniel/yiimp_install_script/releases/latest' | jq -r ".tag_name")
LATESTVER=v0.7.6

if [[ ("${LATESTVER}" > "${VERSION}" && "${LATESTVER}" != "null") ]]; then
RESULT=$(dialog --backtitle " New version ${LATESTVER} available!! Please update to latest..." --stdout --nocancel --default-item 1 --title " Coin Setup ${VERSION} " --menu "Choose one" 13 60 8 \
1 "Build New Coin Daemon from Source Code" \
2 "Add Coin to Dedicated Port and run stratum" \
3 "Update new Stratum" \
' ' "- Upgrade an Existing new Version of this Srypt -" \
4 "Upgrade this scrypt" \
5 Exit)
else
RESULT=$(dialog --stdout --nocancel --default-item 1 --title " Coin Setup ${VERSION} " --menu "Choose one" 13 60 8 \
1 "Build New Coin Daemon from Source Code" \
2 "Add Coin to Dedicated Port and run stratum" \
3 "Update new Stratum" \
' ' "- Upgrade an Existing new Version of this Srypt -" \
4 "Upgrade this scrypt" \
5 Exit)
fi

if [ $RESULT = ]
then
bash $(basename $0) && exit;
fi

if [ $RESULT = 1 ]
then
clear;
cd $STORAGE_ROOT/daemon_builder
source menu1.sh;
fi

if [ $RESULT = 2 ]
then
clear;
cd $STORAGE_ROOT/daemon_builder
source menu2.sh;
fi

if [ $RESULT = 3 ]
then
clear;
cd $STORAGE_ROOT/daemon_builder
source menu3.sh;
fi

if [ $RESULT = 4 ]
then
clear;
cd $STORAGE_ROOT/daemon_builder
source menu4.sh;
fi

if [ $RESULT = 5 ]
then
clear;
exit;
fi