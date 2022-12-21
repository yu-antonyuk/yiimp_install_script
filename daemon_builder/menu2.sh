#!/usr/bin/env bash
#####################################################
# Updated by Afiniel for crypto use...
#####################################################
source /etc/yiimpool.conf
FUNC=/etc/functionscoin.sh
if [[ ! -f "$FUNC" ]]; then
	source /etc/functions.sh
else
	source /etc/functionscoin.sh
fi
cd $STORAGE_ROOT/daemon_builder

RESULT=$(dialog --stdout --title "DaemonBuilder" --menu "Choose one" -1 60 7 \
1 "Install Berkeley 4.x Coin with autogen file" \
2 "Install Berkeley 5.1 Coin with autogen file" \
3 "Install Berkeley 5.3 Coin with autogen file" \
4 "Install Coin with makefile.unix file" \
5 "Install Coin with CMake file" \
6 Exit)
if [ $RESULT = ]
then
bash $(basename $0) && exit;
fi

if [ $RESULT = 1 ]
then
clear;
echo '
autogen=true
berkeley="4.8"
' | sudo -E tee $STORAGE_ROOT/daemon_builder/.my.cnf >/dev/null 2>&1;
source source.sh;
fi

if [ $RESULT = 2 ]
then
clear;
echo '
autogen=true
berkeley="5.1"
' | sudo -E tee $STORAGE_ROOT/daemon_builder/.my.cnf >/dev/null 2>&1;
source source.sh;
fi

if [ $RESULT = 3 ]
then
clear;
echo '
autogen=true
berkeley="5.3"
' | sudo -E tee $STORAGE_ROOT/daemon_builder/.my.cnf >/dev/null 2>&1;
source source.sh;
fi

if [ $RESULT = 4 ]
then
clear;
echo '
autogen=false
' | sudo -E tee $STORAGE_ROOT/daemon_builder/.my.cnf >/dev/null 2>&1;
source source.sh;
fi

if [ $RESULT = 5 ]
then
clear;
echo '
autogen=false
cmake=true
' | sudo -E tee $STORAGE_ROOT/daemon_builder/.my.cnf >/dev/null 2>&1;
source source.sh;
fi

if [ $RESULT = 6 ]
then
clear;
exit;
fi