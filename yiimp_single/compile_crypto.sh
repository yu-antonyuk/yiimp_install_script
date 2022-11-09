#!/usr/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
##################################################################################

source /etc/functions.sh
source /etc/yiimpool.conf

set -eu -o pipefail

function print_error {
	read line file <<<$(caller)
	echo "An error occurred in line $line of file $file:" >&2
	sed "${line}q;d" "$file" >&2
}
trap print_error ERR


# Install required packages to compile coin daemons
package_compile_crypto

echo -e "$GREEN Done...$COL_RESET"

# Create DaemonBuilder directory
if [ ! -d $STORAGE_ROOT/daemon_builder ]; then
sudo mkdir -p $STORAGE_ROOT/daemon_builder
fi

# Copy DaemonBuilder files to DaemonBuilder directory
echo -e "$YELLOW => Copying DaemonBuilder files  <= $COL_RESET"
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

set +eu +o pipefail
cd $HOME/yiimp_install_script/yiimp_single