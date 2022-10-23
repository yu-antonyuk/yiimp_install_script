#!/usr/bin/env bash
#####################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by finiel for yiimpool use...
#####################################################

source /etc/functions.sh
cd ~/yiimp_install_script/conf
clear

# Get logged in user name
whoami=$(whoami)
echo -e " Modifying existing user $whoami for yiimpool support."
sudo usermod -aG sudo ${whoami}

echo '# yiimp
# It needs passwordless sudo functionality.
'""''"${whoami}"''""' ALL=(ALL) NOPASSWD:ALL
' | sudo -E tee /etc/sudoers.d/${whoami} >/dev/null 2>&1

echo '
cd ~/yiimp_install_script/conf
bash start.sh
' | sudo -E tee /usr/bin/yiimpool >/dev/null 2>&1
sudo chmod +x /usr/bin/yiimpool

# Check required files and set global variables
cd $HOME/yiimp_install_script/conf

source pre_setup.sh

# Create the STORAGE_USER and STORAGE_ROOT directory if they don't already exist.
if ! id -u $STORAGE_USER >/dev/null 2>&1; then
    sudo useradd -m $STORAGE_USER
fi
if [ ! -d $STORAGE_ROOT ]; then
    sudo mkdir -p $STORAGE_ROOT
fi

# Save the global options in /etc/yiimpool.conf so that standalone
# tools know where to look for data.
echo 'STORAGE_USER='"${STORAGE_USER}"'
STORAGE_ROOT='"${STORAGE_ROOT}"'
PUBLIC_IP='"${PUBLIC_IP}"'
PUBLIC_IPV6='"${PUBLIC_IPV6}"'
DISTRO='"${DISTRO}"'
FIRST_TIME_SETUP='"${FIRST_TIME_SETUP}"'
PRIVATE_IP='"${PRIVATE_IP}"'' | sudo -E tee /etc/yiimpool.conf >/dev/null 2>&1

# Create the donationaddress.conf in /etc/donation.conf so that standalone
echo 'BTCDON='"bc1q582gdvyp09038hp9n5sfdtp0plkx5x3yrhq05y"'
BCHDONATION='"qzz0aff2k0xnwyzg7k9fcxlndtaj4wa65uxteqe84m"'
DOGEDON='"DSzcmyCRi7JeN4XUiV2qYhRQAydNv7A1Yb"'
LTCDON='"ltc1qqw7cv4snx9ctmpcf25x26lphqluly4w6m073qw"'
ETHDON='"0x50C7d0BF9714dBEcDc1aa6Ab0E72af8e6Ce3b0aB"'' | sudo -E tee /etc/yiimpooldonate.conf >/dev/null 2>&1

cd ~
sudo setfacl -m u:${whoami}:rwx /home/${whoami}/yiimp_install_script
clear
echo -e " Your User has been modified for yiimpool support..."
echo -e "$RED You must reboot the system for the new permissions to update and type$COL_RESET $GREEN yiimpool$COL_RESET $RED to continue setup$COL_RESET"
exit 0
