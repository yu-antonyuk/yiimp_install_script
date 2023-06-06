#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
##################################################################################

clear
source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf
source $HOME/yiimp_install_script/yiimp_single/.wireguard.install.cnf

set -eu -o pipefail

function print_error {
	read line file <<<$(caller)
	echo "An error occurred in line $line of file $file:" >&2
	sed "${line}q;d" "$file" >&2
}
trap print_error ERR

term_art
echo -e "$MAGENTA    <-------------------------->$COL_RESET"
echo -e "$MAGENTA     <--$YELLOW System Configuration$MAGENTA -->$COL_RESET"
echo -e "$MAGENTA    <-------------------------->$COL_RESET"

# Set timezone to UTC
echo
# echo -e "$YELLOW =>  Setting TimeZone to$GREEN UTC <= $COL_RESET"
if [ ! -f /etc/timezone ]; then
	echo "Setting timezone to UTC."
	sudo echo "Etc/UTC" > /etc/timezone
	restart_service rsyslog
fi
echo

sudo apt-get install -y software-properties-common build-essential

# CertBot
if [[ ("$DISTRO" == "16") ]]; then
	echo
	echo -e "$MAGENTA => Installing CertBot PPA <= $COL_RESET"
	sudo add-apt-repository -y ppa:certbot/certbot
	sudo apt-get update
	echo -e "$GREEN => Complete$COL_RESET"
fi

if [[ ("$DISTRO" == "18") ]]; then
	echo
	echo -e "$MAGENTA => Installing CertBot PPA <= $COL_RESET"
	sudo add-apt-repository -y ppa:certbot/certbot
	sudo apt-get update
	echo -e "$GREEN => Complete$COL_RESET"
fi

if [[ ("$DISTRO" == "20") ]]; then
	echo
	echo -e "$MAGENTA => Installing CertBot PPA <= $COL_RESET"
	sudo apt install -y snapd
	sudo snap install core; sudo snap refresh core
	sudo snap install --classic certbot
	sudo ln -s /snap/bin/certbot /usr/bin/certbot

	echo -e "$GREEN => Complete$COL_RESET"
fi
# MariaDB
echo
echo -e "$MAGENTA =>  Installing MariaDB <= $COL_RESET"
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8

if [[ "$DISTRO" == "18" ]]; then
    sudo add-apt-repository 'deb [arch=amd64,arm64,i386,ppc64el] http://mirror.one.com/mariadb/repo/10.4/ubuntu bionic main' >/dev/null 2>&1
fi

if [[ "$DISTRO" == "20" ]]; then
    sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.one.com/mariadb/repo/10.4/ubuntu focal main' >/dev/null 2>&1
fi

if [[ "$DISTRO" == "16" ]]; then
    sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.one.com/mariadb/repo/10.4/ubuntu xenial main' >/dev/null 2>&1
fi

echo -e "$GREEN => Complete$COL_RESET"

# Upgrade System Files
sudo apt-get update
sudo apt-get upgrade -y

if [ ! -f /boot/grub/menu.lst ]; then
	apt_get_quiet upgrade
else
	sudo rm /boot/grub/menu.lst
	sudo update-grub-legacy-ec2 -y
	apt_get_quiet upgrade
fi

# Dist Upgrade
apt_get_quiet dist-upgrade

apt_get_quiet autoremove

echo
echo -e "$MAGENTA => Installing Base system packages <= $COL_RESET"
sudo apt-get install -y python3 python3-dev python3-pip \
	wget curl git sudo coreutils bc \
	haveged pollinate unzip \
	unattended-upgrades cron ntp fail2ban screen rsyslog lolcat nginx

# ### Seed /dev/urandom
echo -e "$GREEN => Complete$COL_RESET"
echo
echo -e "$YELLOW => Initializing system random number generator <= $COL_RESET"
dd if=/dev/random of=/dev/urandom bs=1 count=32 2>/dev/null
sudo pollinate -q -r
echo -e "$GREEN => Complete$COL_RESET"

echo
echo -e "$YELLOW => Initializing UFW Firewall <= $COL_RESET"
set +eu +o pipefail
if [ -z "${DISABLE_FIREWALL:-}" ]; then
	# Install `ufw` which provides a simple firewall configuration.
	sudo apt-get install -y ufw
	echo
	echo -e "$YELLOW => Allow incoming connections to SSH <= $COL_RESET"
	echo
	ufw_allow ssh
	sleep 0.5
	echo -e "$YELLOW ssh port:$GREEN OPEN $COL_RESET"
	echo
	sleep 0.5
	ufw_allow http
	echo -e "$YELLOW http port:$GREEN OPEN $COL_RESET"
	echo
	sleep 0.5
	ufw_allow https
	echo -e "$YELLOW https port:$GREEN OPEN $COL_RESET"
	echo
	# ssh might be running on an alternate port. Use sshd -T to dump sshd's #NODOC
	# settings, find the port it is supposedly running on, and open that port #NODOC
	# too. #NODOC
	SSH_PORT=$(sshd -T 2>/dev/null | grep "^port " | sed "s/port //") #NODOC
	if [ ! -z "$SSH_PORT" ]; then
		if [ "$SSH_PORT" != "22" ]; then

			echo -e "$YELLOW => Allow incoming connections to SSH <= $COL_RESET"
			echo
			echo -e "$YELLOW Opening alternate SSH port:$GREEN $SSH_PORT $COL_RESET"
			echo
			ufw_allow $SSH_PORT
			sleep 0.5
			echo
			echo -e "$YELLOW http port:$GREEN OPEN $COL_RESET"
			ufw_allow http
			sleep 0.5
			echo
			echo -e "$YELLOW https port:$GREEN OPEN $COL_RESET"
			ufw_allow https
			sleep 0.5
			echo

		fi
	fi

	sudo ufw --force enable
fi
set -eu -o pipefail
echo
echo -e "$MAGENTA =>  Installing YiiMP Required system packages <= $COL_RESET"
if [ -f /usr/sbin/apache2 ]; then
	echo Removing apache...
	sudo apt-get -y purge apache2 apache2-*
	sudo apt-get -y --purge autoremove
fi

sudo apt-get update

# Installing Installing php7.3
echo
echo -e "$CYAN => Installing php7.3 : $COL_RESET"
sleep 3

sudo apt -y update

if [ ! -f /etc/apt/sources.list.d/ondrej-php-bionic.list ]; then
	sudo add-apt-repository -y ppa:ondrej/php
fi
sudo apt -y update

# TODO Add  app_install back.
if [[ ("$DISTRO" == "16") ]]; then
	sudo apt-get install -y php7.3-fpm php7.3-opcache php7.3 php7.3-common php7.3-gd php7.3-mysql php7.3-imap php7.3-cli
	sudo apt-get install -y php7.3-cgi php-pear php-auth imagemagick libruby php7.3-curl php7.3-intl php7.3-pspell mcrypt
	sudo apt-get install -y php7.3-recode php7.3-sqlite3 php7.3-tidy php7.3-xmlrpc php7.3-xsl memcached php-memcache php-imagick
	sudo apt-get install -y php-gettext php7.3-zip php7.3-mbstring php7.3-memcache php7.3-memcached
else
	sudo apt-get install -y php7.3-fpm php7.3-opcache php7.3 php7.3-common php7.3-gd php7.3-mysql php7.3-imap php7.3-cli
	sudo apt-get install -y php7.3-cgi php-pear imagemagick libruby php7.3-curl php7.3-intl php7.3-pspell mcrypt
	sudo apt-get install -y php7.3-recode php7.3-sqlite3 php7.3-tidy php7.3-xmlrpc php7.3-xsl memcached php-memcache php-imagick php7.3-zip
	sudo apt-get install -y php7.3-mbstring libpsl-dev libnghttp2-dev php7.3-memcache php7.3-memcached php-curl
	sudo apt-get install -y php-mbstring php-zip php-gd php-json
	sudo phpenmod mbstring
fi
if [[ ("$DISTRO" == "18") ]]; then
	sudo apt-get install -y php-gettext
fi
if [[ ("$DISTRO" == "20") ]]; then
	sudo apt install -y php8.2-fpm php8.2-opcache php8.2 php8.2-common php8.2-gd php8.2-mysql php8.2-imap php8.2-cli
	sudo apt install -y php8.2-cgi php8.2-curl php8.2-intl php8.2-pspell
	sudo apt install -y php8.2-sqlite3 php8.2-tidy php8.2-xmlrpc php8.2-xsl php8.2-zip
	sudo apt install -y php8.2-mbstring php8.2-memcache php8.2-memcached
	# sleep 2
	#  sudo systemctl start php8.2-fpm
	# sudo systemctl status php8.2-fpm | sed -n "1,3p"
fi

# Suppress Upgrade Prompts
# When Ubuntu 20 comes out, we don't want users to be prompted to upgrade,
# because we don't yet support it.
if [ -f /etc/update-manager/release-upgrades ]; then
	sudo editconf.py /etc/update-manager/release-upgrades Prompt=never
	sudo rm -f /var/lib/ubuntu-release-upgrader/release-upgrade-available
fi

# fix CDbConnection failed to open the DB connection.
# echo
echo -e "$CYAN => Fixing DBconnection issue $COL_RESET"
# sudo apt-get install -y php8.1-mysql
sudo update-alternatives --set php /usr/bin/php7.3
echo

echo
echo -e "$CYAN =>  Clone Yiimp Repo <= $COL_RESET"
sudo git clone ${YiiMPRepo} $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
if [[ ("$CoinPort" == "yes") ]]; then
	cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
	sudo git fetch
	sudo git checkout dev >/dev/null 2>&1
fi

service nginx restart

set +eu +o pipefail
cd $HOME/yiimp_install_script/yiimp_single
