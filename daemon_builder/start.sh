#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
##################################################################################

source /etc/functions.sh
source /etc/yiimpool.conf

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

# Create DaemonBuilder directory
if [ ! -d $STORAGE_ROOT/daemon_builder ]; then
sudo mkdir -p $STORAGE_ROOT/daemon_builder
fi

source requirements.sh
source berkeley.sh

echo -e "$CYAN => Installing daemonbuilder $COL_RESET"
cd $HOME/yiimp_install_script/daemon_builder
sudo cp -r $HOME/yiimp_install_script/daemon_builder/* $STORAGE_ROOT/daemon_builder

# Enable DaemonBuilder
echo '
#!/usr/bin/env bash
source /etc/yiimpool.conf
source /etc/functions.sh
cd $STORAGE_ROOT/daemon_builder
bash start.sh
cd ~
' | sudo -E tee /usr/bin/daemonbuilder >/dev/null 2>&1

# Set permissions
sudo chmod +x /usr/bin/daemonbuilder
echo -e "$GREEN Done...$COL_RESET"

echo '#!/bin/sh
USERSERVER='"${whoami}"'
PATH_STRATUM='"${path_stratum}"'
FUNCTION_FILE='"${FUNCTIONFILE}"'
VERSION='"${TAG}"'
BTCDEP='"${BTCDEP}"'
LTCDEP='"${LTCDEP}"'
ETHDEP='"${ETHDEP}"'
DOGEDEP='"${DOGEDEP}"''| sudo -E tee ${absolutepath}/${installtoserver}/conf/info.sh >/dev/null 2>&1
hide_output sudo chmod +x ${absolutepath}/${installtoserver}/conf/info.sh

set +eu +o pipefail
cd $HOME/yiimp_install_script/yiimp_single