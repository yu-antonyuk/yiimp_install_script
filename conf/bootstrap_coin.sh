#!/usr/bin/env bash
#########################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by Afiniel for yiimpool use...
# This script is intended to be ran from the yiimpool installer
#########################################################

if [ -z "${TAG}" ]; then
	TAG=v0.4.2
fi

# Clone the yiimpool repository if it doesn't exist.
if [ ! -d $HOME/yiimpool/daemon_builder ]; then
	echo Downloading yiimpool Daemon Builder Installer ${TAG}. . .
	git clone \
		-b ${TAG} --depth 1 \
		https://github.com/afiniel/daemonbuilder_setup \
		$HOME/yiimp_install_script/daemon_builder \
		< /dev/null 2> /dev/null

	echo
fi

# Change directory to it.
cd $HOME/yiimp_install_script/daemon_builder

# Update it.
sudo chown -R $USER $HOME/yiimpool/install/.git/
if [ "${TAG}" != `git describe --tags` ]; then
	echo Updating Daemon Builder Installer to ${TAG} . . .
	git fetch --depth 1 --force --prune origin tag ${TAG}
	if ! git checkout -q ${TAG}; then
		echo "Update failed. Did you modify something in `pwd`?"
		exit
	fi
	echo
fi

# Start setup script.
cd $HOME/yiimp_install_script/daemon_builder
source install.sh