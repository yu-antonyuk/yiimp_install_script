#!/usr/bin/env bash
#####################################################
# This is the entry point for configuring the system.
# Updated by Afiniel for crypto use...
#####################################################
source /etc/yiimpool.conf
FUNC=/etc/functionscoin.sh
if [[ ! -f "$FUNC" ]]; then
	source /etc/functions.sh # load our functions
else
	source /etc/functionscoin.sh # load our functions
fi

cd $STORAGE_ROOT/daemon_builder
# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. This is also
# in the management daemon startup script and the cron script.

if ! locale -a | grep en_US.utf8 > /dev/null; then
# Generate locale if not exists
hide_output locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
export NCURSES_NO_UTF8_ACS=1

# Create the temporary installation directory if it doesn't already exist.
echo "$YELLOW Creating the temporary build folder... $COL_RESET"
if [ ! -d $STORAGE_ROOT/daemon_builder/temp_coin_builds ]; then
sudo mkdir -p $STORAGE_ROOT/daemon_builder/temp_coin_builds
fi
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/daemon_builder/temp_coin_builds

message_box "DaemonBuilder" \
"Warning! This version of the daemonBuilder only works with servers setup with the Yiimp install script - Afiniel fork!"

# Start the installation.
source menu.sh

clear
echo -e " Installation of your coin daemon is $GREEN completed! $COL_RESET"
echo -e " Type $YELLOW daemonbuilder $COL_RESET at anytime to install a new coin!"