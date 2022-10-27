#!/bin/bash

###########################################################################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox                            #
# Updated by Afiniel for crypto use...                                                                    #
# This script is intended to be run like this:                                                            #
#                                                                                                         #
#  https://raw.githubusercontent.com/afiniel/yiimp_install_script/master/start.sh | bash                  #
#                                                                                                         #
#                                                                                                         #
###########################################################################################################


# Install git and Clone yiimp_install_script

echo Installing git . . .
apt-get -q -q update
apt-get -q -q install -y git < /dev/null
echo

echo Downloading Yiimp Install Scrip v0.4.3. . .
git clone https://github.com/afiniel/yiimp_install_script.git "$HOME"/yiimp_install_script/install < /dev/null 2> /dev/null
echo

# Start Install script.
bash $HOME/yiimp_install_script/install/start.sh