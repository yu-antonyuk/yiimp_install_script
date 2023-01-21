#!/bin/bash
################################################################################
# Original Author:   crombiecrunch
# Modified by : Xavatar (https://github.com/xavatar/yiimp_install_scrypt)
# Web: https://www.xavatar.com
#
#   Install yiimp on Ubuntu 16.04/18.04 running Nginx, MariaDB, and php7.3
#   v0.2 (update Avril, 2020)
#
# Current modified by : Afiniel
# web: https://www.afiniel.xyz
# Program:
#   Install yiimp on Ubuntu 16.04/18.04 running Nginx, MariaDB, and php7.3
#   v0.3 (2022-06-14 Fixed solo fee in serverconfig.php)
#        (2022-06-14 added block.sql and coins_thepool_life.sql dump)
#
################################################################################

output() {
    printf "\E[0;33;40m"
    echo $1
    printf "\E[0m"
}

displayErr() {
    echo
    echo $1
    echo
    exit 1
}

#Add user group sudo + no password
whoami=$(whoami)
sudo usermod -aG sudo ${whoami}
echo '# yiimp
    # It needs passwordless sudo functionality.
    '""''"${whoami}"''""' ALL=(ALL) NOPASSWD:ALL
    ' | sudo -E tee /etc/sudoers.d/${whoami} >/dev/null 2>&1

#Copy needed files
cd $HOME/yiimp_install_script
sudo cp -r conf/functions.sh /etc/
#sudo cp -r utils/screen-scrypt.sh /etc/
#sudo cp -r utils/screen-stratum.sh /etc/
sudo cp -r conf/editconf.py /usr/bin/
sudo chmod +x /usr/bin/editconf.py
sudo chmod +x /etc/screen-scrypt.sh

source /etc/functions.sh

daemonbuiler_files
term_art
echo
# Update package and Upgrade Ubuntu
echo -e "$CYAN => Updating system and installing required packages $COL_RESET"

sleep 3
echo
hide_output sudo apt -y update
hide_output sudo apt -y upgrade
hide_output sudo apt -y autoremove
hide_output sudo apt-get install -y software-properties-common
apt_install dialog python3 python3-pip acl nano apt-transport-https
apt_install figlet
echo -e "$GREEN Done$COL_RESET"

source conf/prerequisite.sh
sleep 3
source conf/getip.sh

echo 'PUBLIC_IP='"${PUBLIC_IP}"'
    PUBLIC_IPV6='"${PUBLIC_IPV6}"'
    DISTRO='"${DISTRO}"'
    PRIVATE_IP='"${PRIVATE_IP}"'' | sudo -E tee conf/pool.conf >/dev/null 2>&1

term_art
echo -e "$YELLOW Make sure you double check before hitting enter!$RED Only one shot at these! $COL_RESET"
echo
read -e -p "Domain Name (Enter Domain name: example.com or ip of your server): " server_name
read -e -p "Are you using a subdomain (mycryptopool.example.com?) [y/N]: " sub_domain
read -e -p "Set Pool to AutoExchange? i.e. mine any coin with BTC address? [y/N]: " BTC
read -e -p "Enter the Public IP of the system you will use to access the admin panel (http://www.whatsmyip.org/): " Public
read -e -p "Install Fail2ban? [Y/n] : " install_fail2ban
read -e -p "Install UFW and configure ports? [Y/n] : " UFW
read -e -p "Install LetsEncrypt SSL? IMPORTANT! You MUST have your domain name pointed to this server [Y/n]: " ssl_install
echo
term_art
# Installing Nginx
echo
echo -e "$MAGENTA => Installing Nginx server $COL_RESET"
echo
sleep 3

if [ -f /usr/sbin/apache2 ]; then
    echo -e "Removing apache..."
    hide_output apt-get -y purge apache2 apache2-*
    hide_output apt-get -y --purge autoremove
fi

apt_install nginx
hide_output sudo rm /etc/nginx/sites-enabled/default
hide_output sudo systemctl start nginx.service
hide_output sudo systemctl enable nginx.service
hide_output sudo systemctl start cron.service
hide_output sudo systemctl enable cron.service
sleep 5
sudo systemctl status nginx | sed -n "1,3p"
echo
echo -e "$GREEN Done$COL_RESET"

# Making Nginx a bit hard
echo 'map $http_user_agent $blockedagent {
    default         0;
    ~*malicious     1;
    ~*bot           1;
    ~*backdoor      1;
    ~*crawler       1;
    ~*bandit        1;
    }
    ' | sudo -E tee /etc/nginx/blockuseragents.rules >/dev/null 2>&1

# Installing Mariadb
echo
echo
echo -e "$MAGENTA => Installing Mariadb Server $COL_RESET"
echo
sleep 3

# Create random password
rootpasswd=$(openssl rand -base64 12)
export DEBIAN_FRONTEND="noninteractive"
apt_install mariadb-server
hide_output sudo systemctl start mysql
hide_output sudo systemctl enable mysql
sleep 5
sudo systemctl status mysql | sed -n "1,3p"
echo
echo -e "$GREEN Done$COL_RESET"

# Installing Installing php7.3
echo
echo -e "$MAGENTA => Installing php7.3  $COL_RESET"
echo
sleep 3

source conf/pool.conf
if [ ! -f /etc/apt/sources.list.d/ondrej-php-bionic.list ]; then
    hide_output sudo add-apt-repository -y ppa:ondrej/php
fi
hide_output sudo apt -y update

if [[ ("$DISTRO" == "16") ]]; then
apt_install php7.3-fpm php7.3-opcache php7.3-fpm php7.3 php7.3-common php7.3-gd \
php7.3-mysql php7.3-imap php7.3-cli php7.3-cgi \
php-pear php-auth-sasl mcrypt imagemagick libruby \
php7.3-curl php7.3-intl php7.3-pspell php7.3-recode php7.3-sqlite3 \
php7.3-tidy php7.3-xmlrpc php7.3-xsl memcached php-memcache \
php-imagick php-gettext php7.3-zip php7.3-mbstring \
fail2ban ntpdate python3 python3-dev python3-pip \
curl git sudo coreutils pollinate unzip unattended-upgrades cron \
pwgen libgmp3-dev libmysqlclient-dev libcurl4-gnutls-dev \
libkrb5-dev libldap2-dev libidn11-dev gnutls-dev librtmp-dev \
build-essential libtool autotools-dev automake pkg-config libevent-dev bsdmainutils libssl-dev \
automake cmake gnupg2 ca-certificates lsb-release nginx certbot libsodium-dev \
libnghttp2-dev librtmp-dev libssh2-1 libssh2-1-dev libldap2-dev libidn11-dev libpsl-dev libkrb5-dev php7.3-memcache php7.3-memcached memcached \
php8.1-mysql
else
apt_install php7.3-fpm php7.3-opcache php7.3-fpm php7.3 php7.3-common php7.3-gd \
php7.3-mysql php7.3-imap php7.3-cli php7.3-cgi \
php-pear php-auth-sasl mcrypt imagemagick libruby \
php7.3-curl php7.3-intl php7.3-pspell php7.3-recode php7.3-sqlite3 \
php7.3-tidy php7.3-xmlrpc php7.3-xsl memcached php-memcache \
php-imagick php-gettext php7.3-zip php7.3-mbstring \
fail2ban ntpdate python3 python3-dev python3-pip \
curl git sudo coreutils pollinate unzip unattended-upgrades cron \
pwgen libgmp3-dev libmysqlclient-dev libcurl4-gnutls-dev \
libkrb5-dev libldap2-dev libidn11-dev gnutls-dev librtmp-dev \
build-essential libtool autotools-dev automake pkg-config libevent-dev bsdmainutils libssl-dev \
libpsl-dev libnghttp2-dev automake cmake gnupg2 ca-certificates lsb-release nginx certbot libsodium-dev \
libnghttp2-dev librtmp-dev libssh2-1 libssh2-1-dev libldap2-dev libidn11-dev libpsl-dev libkrb5-dev php7.3-memcache php7.3-memcached memcached \
php8.1-mysql
fi

# ### Suppress Upgrade Prompts
# When Ubuntu 20 comes out, we don't want users to be prompted to upgrade,
# because we don't yet support it.
if [ -f /etc/update-manager/release-upgrades ]; then
sudo editconf.py /etc/update-manager/release-upgrades Prompt=never
sudo rm -f /var/lib/ubuntu-release-upgrader/release-upgrade-available
fi

echo -e "$GREEN Done$COL_RESET"

# fix CDbConnection failed to open the DB connection.
echo
echo -e "$CYAN => Fixing DBconnection issue $COL_RESET"
apt_install php8.1-mysql
echo
hide_output service nginx restart

echo -e "$GREEN Done$COL_RESET"

# Generating Random Passwords
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
password2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
AUTOGENERATED_PASS=$(pwgen -c -1 20)

# Test Email
echo
echo -e "$CYAN => Testing to see if server emails are sent $COL_RESET"
echo
sleep 3

if [[ "$root_email" != "" ]]; then
    echo $root_email tee --append ~/.email >sudo
    echo $root_email tee --append ~/.forward >sudo

    if [[ ("$send_email" == "y" || "$send_email" == "Y" || "$send_email" == "") ]]; then
        echo "This is a mail test for the SMTP Service." tee --append /tmp/email.message >sudo
        echo "You should receive this !" tee --append /tmp/email.message >>sudo
        echo "" tee --append /tmp/email.message >>sudo
        echo "Cheers" tee --append /tmp/email.message >>sudo
        sudo sendmail -s "SMTP Testing" $root_email tee --append /tmp/email.message <sudo

        sudo rm -f /tmp/email.message
        echo "Mail sent"
    fi
fi
echo -e "$GREEN Done$COL_RESET"

# Installing Fail2Ban & UFW
echo
echo -e "$CYAN => Some optional installs (Fail2Ban & UFW) $COL_RESET"
echo
sleep 3

if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
    apt_install fail2ban
    sleep 3
    restart_service fail2ban | sed -n "1,3p"
fi

if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then

    apt_install ufw

    hide_output ufw_allow ssh
    hide_output ufw_allow http
    hide_output ufw_allow https

    hide_output sudo ufw --force enable
    sleep 3
    restart_service ufw | sed -n "1,3p"
fi

echo
echo -e "$GREEN Done$COL_RESET"

# Installing PhpMyAdmin
echo
echo -e "$MAGENTA => Installing phpMyAdmin $COL_RESET"
echo
sleep 3

echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $rootpasswd" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $AUTOGENERATED_PASS" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $AUTOGENERATED_PASS" | sudo debconf-set-selections

apt_install phpmyadmin

echo -e "$GREEN Done$COL_RESET"

# Installing Yiimp
echo
echo -e "$CYAN => Grabbing$GEEEN Yiimp$CYAN fron Github, building files and setting file structure. $COL_RESET"
echo
sleep 3

# Generating Random Password for stratum
blckntifypass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Compil Blocknotify
cd ~
hide_output git clone https://github.com/afiniel/yiimp.git -b next
cd $HOME/yiimp/blocknotify
sudo sed -i 's/tu8tu5/'$blckntifypass'/' blocknotify.cpp
hide_output sudo make -j8

# Compil iniparser
cd $HOME/yiimp/stratum/iniparser
hide_output sudo make -j8

# Compil Stratum
cd $HOME/yiimp/stratum
if [[ ("$BTC" == "y" || "$BTC" == "Y") ]]; then
    sudo sed -i 's/CFLAGS += -DNO_EXCHANGE/#CFLAGS += -DNO_EXCHANGE/' $HOME/yiimp/stratum/Makefile
fi
hide_output sudo make -j8

# Copy Files (Blocknotify,iniparser,Stratum)
cd $HOME/yiimp
sudo sed -i 's/myadmin/'AdminPanel'/' $HOME/yiimp/web/yaamp/modules/site/SiteController.php
sudo cp -r $HOME/yiimp/web /var/
sudo mkdir -p /var/stratum

# Stratum
cd $HOME/yiimp/stratum
sudo cp -a config.sample/. /var/stratum/config
sudo cp -r stratum /var/stratum
sudo cp -r run.sh /var/stratum

# Blocknotify
cd $HOME/yiimp
sudo cp -r $HOME/yiimp/bin/. /bin/
sudo cp -r $HOME/yiimp/blocknotify/blocknotify /usr/bin/
sudo cp -r $HOME/yiimp/blocknotify/blocknotify /var/stratum/
sudo mkdir -p /etc/yiimp
sudo mkdir -p /$HOME/backup/

#fixing yiimp
sudo sed -i "s|ROOTDIR=/data/yiimp|ROOTDIR=/var|g" /bin/yiimp

#fixing run.sh
sudo rm -r /var/stratum/config/run.sh
echo '
    #!/bin/bash
    ulimit -n 10240
    ulimit -u 10240
    cd /var/stratum
    while true; do
    ./stratum /var/stratum/config/$1
    sleep 2
    done
    exec bash
    ' | sudo -E tee /var/stratum/config/run.sh >/dev/null 2>&1
sudo chmod +x /var/stratum/config/run.sh

echo -e "$GREEN Done$COL_RESET"

# Update Timezone
echo
echo -e "$CYAN => Update default timezone $COL_RESET"
echo

echo -e "$YELLOW Setting TimeZone to$GREEN UTC$COL_RESET"
if [ ! -f /etc/timezone ]; then

    echo "Setting timezone to UTC."
    echo "Etc/UTC" /etc/timezone >sudo
    restart_service rsyslog

fi
sudo systemctl status rsyslog | sed -n "1,3p"
echo
echo -e "$GREEN Done$COL_RESET"

# Creating webserver initial config file
echo
echo -e "$CYAN => Creating webserver initial config file $COL_RESET"
echo

# Adding user to group, creating dir structure, setting permissions
sudo mkdir -p /var/www/$server_name/html

if [[ ("$sub_domain" == "y" || "$sub_domain" == "Y") ]]; then
    echo 'include /etc/nginx/blockuseragents.rules;
	server {
	if ($blockedagent) {
                return 403;
        }
        if ($request_method !~ ^(GET|HEAD|POST)$) {
        return 444;
        }
        listen 80;
        listen [::]:80;
        server_name '"${server_name}"';
        root "/var/www/'"${server_name}"'/html/web";
        index index.html index.htm index.php;
        charset utf-8;
    
        location / {
        try_files $uri $uri/ /index.php?$args;
        }
        location @rewrite {
        rewrite ^/(.*)$ /index.php?r=$1;
        }
    
        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }
    
        access_log /var/log/nginx/'"${server_name}"'.app-access.log;
        error_log /var/log/nginx/'"${server_name}"'.app-error.log;
    
        # allow larger file uploads and longer script runtimes
        client_body_buffer_size  50k;
        client_header_buffer_size 50k;
        client_max_body_size 50k;
        large_client_header_buffers 2 50k;
        sendfile off;
    
        location ~ ^/index\.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_connect_timeout 300;
            fastcgi_send_timeout 300;
            fastcgi_read_timeout 300;
	    try_files $uri $uri/ =404;
        }
		location ~ \.php$ {
        	return 404;
        }
		location ~ \.sh {
		return 404;
        }
		location ~ /\.ht {
		deny all;
        }
		location ~ /.well-known {
		allow all;
        }
		location /phpmyadmin {
  		root /usr/share/;
  		index index.php;
  		try_files $uri $uri/ =404;
  		location ~ ^/phpmyadmin/(doc|sql|setup)/ {
    		deny all;
  	  }
  		location ~ /phpmyadmin/(.+\.php)$ {
    		fastcgi_pass unix:/run/php/php7.3-fpm.sock;
    		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    		include fastcgi_params;
    		include snippets/fastcgi-php.conf;
  	    }
      }
    }
    ' | sudo -E tee /etc/nginx/sites-available/$server_name.conf >/dev/null 2>&1

    sudo ln -s /etc/nginx/sites-available/$server_name.conf /etc/nginx/sites-enabled/$server_name.conf
    sudo ln -s /var/web /var/www/$server_name/html
    hide_output sudo systemctl reload php7.3-fpm.service
    hide_output restart_service nginx.service
    echo -e "$GREEN Done$COL_RESET"

    if [[ ("$ssl_install" == "y" || "$ssl_install" == "Y" || "$ssl_install" == "") ]]; then

        # Install SSL (with SubDomain)
        echo
        echo -e "$CYAN => Install LetsEncrypt and setting SSL (with SubDomain) $COL_RESET"
        echo

        apt_install letsencrypt
        sudo letsencrypt certonly -a webroot --webroot-path=/var/web --email "$EMAIL" --agree-tos -d "$server_name"
        sudo rm /etc/nginx/sites-available/$server_name.conf
        sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
        # I am SSL Man!
        echo 'include /etc/nginx/blockuseragents.rules;
	server {
	if ($blockedagent) {
                return 403;
        }
        if ($request_method !~ ^(GET|HEAD|POST)$) {
        return 444;
        }
        listen 80;
        listen [::]:80;
        server_name '"${server_name}"';
    	# enforce https
        return 301 https://$server_name$request_uri;
	}
	
	server {
	if ($blockedagent) {
                return 403;
        }
        if ($request_method !~ ^(GET|HEAD|POST)$) {
        return 444;
        }
            listen 443 ssl http2;
            listen [::]:443 ssl http2;
            server_name '"${server_name}"';
        
            root /var/www/'"${server_name}"'/html/web;
            index index.php;
        
            access_log /var/log/nginx/'"${server_name}"'.app-access.log;
            error_log  /var/log/nginx/'"${server_name}"'.app-error.log;
        
            # allow larger file uploads and longer script runtimes
 	        client_body_buffer_size  50k;
            client_header_buffer_size 50k;
            client_max_body_size 50k;
            large_client_header_buffers 2 50k;
            sendfile off;
        
            # strengthen ssl security
            ssl_certificate /etc/letsencrypt/live/'"${server_name}"'/fullchain.pem;
            ssl_certificate_key /etc/letsencrypt/live/'"${server_name}"'/privkey.pem;
            ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            ssl_prefer_server_ciphers on;
            ssl_session_cache shared:SSL:10m;
            ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
            ssl_dhparam /etc/ssl/certs/dhparam.pem;
        
            # Add headers to serve security related headers
            add_header Strict-Transport-Security "max-age=15768000; preload;";
            add_header X-Content-Type-Options nosniff;
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag none;
            add_header Content-Security-Policy "frame-ancestors 'self'";
        
        location / {
        try_files $uri $uri/ /index.php?$args;
        }
        location @rewrite {
        rewrite ^/(.*)$ /index.php?r=$1;
        }
    
        
            location ~ ^/index\.php$ {
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_intercept_errors off;
                fastcgi_buffer_size 16k;
                fastcgi_buffers 4 16k;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
                include /etc/nginx/fastcgi_params;
	    	try_files $uri $uri/ =404;
        }
		location ~ \.php$ {
        	return 404;
        }
		location ~ \.sh {
		return 404;
        }
        
            location ~ /\.ht {
                deny all;
            }
	    location /phpmyadmin {
  		root /usr/share/;
  		index index.php;
  		try_files $uri $uri/ =404;
  		location ~ ^/phpmyadmin/(doc|sql|setup)/ {
    		deny all;
  	}
  		location ~ /phpmyadmin/(.+\.php)$ {
    		fastcgi_pass unix:/run/php/php7.3-fpm.sock;
    		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    		include fastcgi_params;
    		include snippets/fastcgi-php.conf;
  	   }
     }
    }
        
    ' | sudo -E tee /etc/nginx/sites-available/$server_name.conf >/dev/null 2>&1
    fi

    hide_output sudo systemctl reload php7.3-fpm.service
    hide_output restart_service nginx.service
    echo -e "$GREEN Done$COL_RESET"

else

    echo 'include /etc/nginx/blockuseragents.rules;
	server {
	if ($blockedagent) {
                return 403;
        }
        if ($request_method !~ ^(GET|HEAD|POST)$) {
        return 444;
        }
        listen 80;
        listen [::]:80;
        server_name '"${server_name}"' www.'"${server_name}"';
        root "/var/www/'"${server_name}"'/html/web";
        index index.html index.htm index.php;
        charset utf-8;
    
        location / {
        try_files $uri $uri/ /index.php?$args;
        }
        location @rewrite {
        rewrite ^/(.*)$ /index.php?r=$1;
        }
    
        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }
    
        access_log /var/log/nginx/'"${server_name}"'.app-access.log;
        error_log /var/log/nginx/'"${server_name}"'.app-error.log;
    
        # allow larger file uploads and longer script runtimes
 	    client_body_buffer_size  50k;
        client_header_buffer_size 50k;
        client_max_body_size 50k;
        large_client_header_buffers 2 50k;
        sendfile off;
    
        location ~ ^/index\.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_connect_timeout 300;
            fastcgi_send_timeout 300;
            fastcgi_read_timeout 300;
	    try_files $uri $uri/ =404;
        }
		location ~ \.php$ {
        	return 404;
        }
		location ~ \.sh {
		return 404;
        }
		location ~ /\.ht {
		deny all;
        }
		location ~ /.well-known {
		allow all;
        }
		location /phpmyadmin {
  		root /usr/share/;
  		index index.php;
  		try_files $uri $uri/ =404;
  		location ~ ^/phpmyadmin/(doc|sql|setup)/ {
    		deny all;
  	}
  		location ~ /phpmyadmin/(.+\.php)$ {
    		fastcgi_pass unix:/run/php/php7.3-fpm.sock;
    		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    		include fastcgi_params;
    		include snippets/fastcgi-php.conf;
  	    }
      }
    }
    ' | sudo -E tee /etc/nginx/sites-available/$server_name.conf >/dev/null 2>&1

    sudo ln -s /etc/nginx/sites-available/$server_name.conf /etc/nginx/sites-enabled/$server_name.conf
    sudo ln -s /var/web /var/www/$server_name/html
    hide_output sudo systemctl reload php7.3-fpm.service
    hide_output restart_service nginx.service
    echo -e "$GREEN Done$COL_RESET"

    if [[ ("$ssl_install" == "y" || "$ssl_install" == "Y" || "$ssl_install" == "") ]]; then

        # Install SSL (without SubDomain)
        echo
        echo -e "$GREEN Install LetsEncrypt and setting SSL (without SubDomain) $COL_RESET"
        echo
        sleep 3

        apt_install letsencrypt
        sudo letsencrypt certonly -a webroot --webroot-path=/var/web --email "$EMAIL" --agree-tos -d "$server_name" -d www."$server_name"
        sudo rm /etc/nginx/sites-available/$server_name.conf
        sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
        # I am SSL Man!
        echo 'include /etc/nginx/blockuseragents.rules;
	server {
	if ($blockedagent) {
                return 403;
        }
        if ($request_method !~ ^(GET|HEAD|POST)$) {
        return 444;
        }
        listen 80;
        listen [::]:80;
        server_name '"${server_name}"';
    	# enforce https
        return 301 https://$server_name$request_uri;
	}
	
	server {
	if ($blockedagent) {
                return 403;
        }
        if ($request_method !~ ^(GET|HEAD|POST)$) {
        return 444;
        }
            listen 443 ssl http2;
            listen [::]:443 ssl http2;
            server_name '"${server_name}"' www.'"${server_name}"';
        
            root /var/www/'"${server_name}"'/html/web;
            index index.php;
        
            access_log /var/log/nginx/'"${server_name}"'.app-access.log;
            error_log  /var/log/nginx/'"${server_name}"'.app-error.log;
        
            # allow larger file uploads and longer script runtimes
 	        client_body_buffer_size  50k;
            client_header_buffer_size 50k;
            client_max_body_size 50k;
            large_client_header_buffers 2 50k;
            sendfile off;
        
            # strengthen ssl security
            ssl_certificate /etc/letsencrypt/live/'"${server_name}"'/fullchain.pem;
            ssl_certificate_key /etc/letsencrypt/live/'"${server_name}"'/privkey.pem;
            ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            ssl_prefer_server_ciphers on;
            ssl_session_cache shared:SSL:10m;
            ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
            ssl_dhparam /etc/ssl/certs/dhparam.pem;
        
            # Add headers to serve security related headers
            add_header Strict-Transport-Security "max-age=15768000; preload;";
            add_header X-Content-Type-Options nosniff;
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag none;
            add_header Content-Security-Policy "frame-ancestors 'self'";
        
        location / {
        try_files $uri $uri/ /index.php?$args;
        }
        location @rewrite {
        rewrite ^/(.*)$ /index.php?r=$1;
        }
    
        
            location ~ ^/index\.php$ {
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_intercept_errors off;
                fastcgi_buffer_size 16k;
                fastcgi_buffers 4 16k;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
                include /etc/nginx/fastcgi_params;
	    	try_files $uri $uri/ =404;
        }
		location ~ \.php$ {
        	return 404;
        }
		location ~ \.sh {
		return 404;
        }
        
            location ~ /\.ht {
                deny all;
            }
	    location /phpmyadmin {
  		root /usr/share/;
  		index index.php;
  		try_files $uri $uri/ =404;
  		location ~ ^/phpmyadmin/(doc|sql|setup)/ {
    		deny all;
  	}
  		location ~ /phpmyadmin/(.+\.php)$ {
    		fastcgi_pass unix:/run/php/php7.3-fpm.sock;
    		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    		include fastcgi_params;
    		include snippets/fastcgi-php.conf;
  	    }
      }
    }
        
    ' | sudo -E tee /etc/nginx/sites-available/$server_name.conf >/dev/null 2>&1

        echo -e "$GREEN Done$COL_RESET"

    fi
    hide_output sudo systemctl reload php7.3-fpm.service
    hide_output restart_service nginx.service
fi

# Database Setup
echo
echo
echo -e "$CYAN => Setting up the Database $COL_RESET"
echo
sleep 2

# Create database
Q1="CREATE DATABASE IF NOT EXISTS yiimpfrontend;"
Q2="GRANT ALL ON *.* TO 'panel'@'localhost' IDENTIFIED BY '$password';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"
sudo mysql -u root -p="" -e "$SQL"

# Create stratum user
Q1="GRANT ALL ON *.* TO 'stratum'@'localhost' IDENTIFIED BY '$password2';"
Q2="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}"
sudo mysql -u root -p="" -e "$SQL"

#Create my.cnf

echo '
    [clienthost1]
    user=panel
    password='"${password}"'
    database=yiimpfrontend
    host=localhost
    [clienthost2]
    user=stratum
    password='"${password2}"'
    database=yiimpfrontend
    host=localhost
    [myphpadmin]
    user=phpmyadmin
    password='"${AUTOGENERATED_PASS}"'
    [mysql]
    user=root
    password='"${rootpasswd}"'
    ' | sudo -E tee ~/.my.cnf >/dev/null 2>&1
sudo chmod 0600 ~/.my.cnf

# Create keys.php file
echo '  
    <?php
    /* Sample config file to put in /etc/yiimp/keys.php */
    define('"'"'YIIMP_MYSQLDUMP_USER'"'"', '"'"'panel'"'"');
    define('"'"'YIIMP_MYSQLDUMP_PASS'"'"', '"'"''"${password}"''"'"');
    define('"'"'YIIMP_MYSQLDUMP_PATH'"'"', '"'"''"/var/yiimp/sauv"''"'"');
    
    /* Keys required to create/cancel orders and access your balances/deposit addresses */
    define('"'"'EXCH_ALCUREX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_ALTILLY_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BIBOX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BINANCE_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BITTREX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BITSTAMP_SECRET'"'"','"'"''"'"');
    define('"'"'EXCH_BLEUTRADE_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BTER_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_CEXIO_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_CREX24_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_CCEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_COINMARKETS_PASS'"'"', '"'"''"'"');
    define('"'"'EXCH_CRYPTOHUB_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_CRYPTOWATCH_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_DELIONDEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_EMPOEX_SECKEY'"'"', '"'"''"'"');
    define('"'"'EXCH_ESCODEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_EXBITRON_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_GATEIO_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_GRAVIEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_HITBTC_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_JUBI_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_KRAKEN_SECRET'"'"','"'"''"'"');
    define('"'"'EXCH_KUCOIN_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_LIVECOIN_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_POLONIEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_SHAPESHIFT_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_STOCKSEXCHANGE_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_SWIFTEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_TRADEOGRE_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_YOBIT_SECRET'"'"', '"'"''"'"');
    ' | sudo -E tee /etc/yiimp/keys.php >/dev/null 2>&1

echo -e "$GREEN Done$COL_RESET"

# Peforming the SQL import
echo
database_import_sql

# Generating a basic Yiimp serverconfig.php
echo
echo
echo -e "$CYAN => Generating a basic Yiimp serverconfig.php $COL_RESET"
echo
sleep 3

# Make config file
echo '
    <?php
    ini_set('"'"'date.timezone'"'"', '"'"'UTC'"'"');
    define('"'"'YAAMP_LOGS'"'"', '"'"'/var/log/yiimp'"'"');
    define('"'"'YAAMP_HTDOCS'"'"', '"'"'/var/web'"'"');
        
    define('"'"'YAAMP_BIN'"'"', '"'"'/var/bin'"'"');
    
    define('"'"'YAAMP_DBHOST'"'"', '"'"'localhost'"'"');
    define('"'"'YAAMP_DBNAME'"'"', '"'"'yiimpfrontend'"'"');
    define('"'"'YAAMP_DBUSER'"'"', '"'"'panel'"'"');
    define('"'"'YAAMP_DBPASSWORD'"'"', '"'"''"${password}"''"'"');
    
    define('"'"'YAAMP_PRODUCTION'"'"', true);
    define('"'"'YAAMP_RENTAL'"'"', false);
    
    define('"'"'YAAMP_LIMIT_ESTIMATE'"'"', false);
    
    define('"'"'YAAMP_FEES_SOLO'"'"', 1.0);
    
    define('"'"'YAAMP_FEES_MINING'"'"', 0.5);
    define('"'"'YAAMP_FEES_EXCHANGE'"'"', 2);
    define('"'"'YAAMP_FEES_RENTING'"'"', 2);
    define('"'"'YAAMP_TXFEE_RENTING_WD'"'"', 0.002);
    
    define('"'"'YAAMP_PAYMENTS_FREQ'"'"', 2*60*60);
    define('"'"'YAAMP_PAYMENTS_MINI'"'"', 0.001);
    
    define('"'"'YAAMP_ALLOW_EXCHANGE'"'"', false);
    define('"'"'YIIMP_PUBLIC_EXPLORER'"'"', true);
    define('"'"'YIIMP_PUBLIC_BENCHMARK'"'"', false);
    
    define('"'"'YIIMP_FIAT_ALTERNATIVE'"'"', '"'"'USD'"'"'); // USD is main
    define('"'"'YAAMP_USE_NICEHASH_API'"'"', false);
    
    define('"'"'YAAMP_BTCADDRESS'"'"', '"'"'bc1qpnxtg3dvtglrvfllfk3gslt6h5zffkf069nh8r'"'"');
    
    define('"'"'YAAMP_SITE_URL'"'"', '"'"''"${server_name}"''"'"');
    define('"'"'YAAMP_STRATUM_URL'"'"', YAAMP_SITE_URL); // change if your stratum server is on a different host
    define('"'"'YAAMP_SITE_NAME'"'"', '"'"'MyYiimpPool'"'"');
    define('"'"'YAAMP_ADMIN_EMAIL'"'"', '"'"''"${EMAIL}"''"'"');
    define('"'"'YAAMP_ADMIN_IP'"'"', '"'"''"${Public}"''"'"'); // samples: "80.236.118.26,90.234.221.11" or "10.0.0.1/8"
    
    define('"'"'YAAMP_ADMIN_WEBCONSOLE'"'"', true);
    define('"'"'YAAMP_CREATE_NEW_COINS'"'"', false);
    define('"'"'YAAMP_NOTIFY_NEW_COINS'"'"', false);
    
    define('"'"'YAAMP_DEFAULT_ALGO'"'"', '"'"'x11'"'"');
    
    define('"'"'YAAMP_USE_NGINX'"'"', true);
    
    // Exchange public keys (private keys are in a separate config file)
    define('"'"'EXCH_ALCUREX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_ALTILLY_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BIBOX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BINANCE_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BITTREX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BITSTAMP_SECRET'"'"','"'"''"'"');
    define('"'"'EXCH_BLEUTRADE_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_BTER_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_CEXIO_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_CREX24_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_CCEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_COINMARKETS_PASS'"'"', '"'"''"'"');
    define('"'"'EXCH_CRYPTOHUB_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_CRYPTOWATCH_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_DELIONDEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_EMPOEX_SECKEY'"'"', '"'"''"'"');
    define('"'"'EXCH_ESCODEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_GATEIO_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_GRAVIEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_HITBTC_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_JUBI_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_KRAKEN_SECRET'"'"','"'"''"'"');
    define('"'"'EXCH_KUCOIN_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_LIVECOIN_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_POLONIEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_SHAPESHIFT_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_STOCKSEXCHANGE_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_SWIFTEX_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_TRADEOGRE_SECRET'"'"', '"'"''"'"');
    define('"'"'EXCH_YOBIT_SECRET'"'"', '"'"''"'"');
    
    // Automatic withdraw to Yaamp btc wallet if btc balance > 0.3
    define('"'"'EXCH_AUTO_WITHDRAW'"'"', 0.3);
    
    // nicehash keys deposit account & amount to deposit at a time
    define('"'"'NICEHASH_API_KEY'"'"','"'"'f96c65a7-3d2f-4f3a-815c-cacf00674396'"'"');
    define('"'"'NICEHASH_API_ID'"'"','"'"'825979'"'"');
    define('"'"'NICEHASH_DEPOSIT'"'"','"'"'3ABoqBjeorjzbyHmGMppM62YLssUgJhtuf'"'"');
    define('"'"'NICEHASH_DEPOSIT_AMOUNT'"'"','"'"'0.01'"'"');
    
    $cold_wallet_table = array(
	'"'"'bc1qpnxtg3dvtglrvfllfk3gslt6h5zffkf069nh8r'"'"' => 0.10,
    );
    
    // Sample fixed pool fees
    $configFixedPoolFees = array(
        '"'"'zr5'"'"' => 2.0,
        '"'"'scrypt'"'"' => 20.0,
        '"'"'sha256'"'"' => 5.0,
     );
     
     // Sample fixed pool fees solo
    $configFixedPoolFeesSolo = array(
        '"'"'zr5'"'"' => 2.0,
        '"'"'scrypt'"'"' => 20.0,
        '"'"'sha256'"'"' => 5.0,
        
    );
    
    // Sample custom stratum ports
    $configCustomPorts = array(
    //	'"'"'x11'"'"' => 7000,
    );
    
    // mBTC Coefs per algo (default is 1.0)
    $configAlgoNormCoef = array(
    //	'"'"'x11'"'"' => 5.0,
    );
    ' | sudo -E tee /var/web/serverconfig.php >/dev/null 2>&1

echo -e "$GREEN Done$COL_RESET"

# Updating stratum config files with database connection info
echo
echo -e "$CYAN => Updating stratum config files with database connection info $COL_RESET"
echo
sleep 3

cd /var/stratum/config
sudo sed -i 's/password = tu8tu5/password = '$blckntifypass'/g' *.conf
sudo sed -i 's/server = yaamp.com/server = '$server_name'/g' *.conf
sudo sed -i 's/host = yaampdb/host = localhost/g' *.conf
sudo sed -i 's/database = yaamp/database = yiimpfrontend/g' *.conf
sudo sed -i 's/username = root/username = stratum/g' *.conf
sudo sed -i 's/password = patofpaq/password = '$password2'/g' *.conf
cd ~
echo -e "$GREEN Done$COL_RESET"

# Final Directory permissions
echo
echo
echo -e "$CYAN => Final Directory permissions $COL_RESET"
echo
sleep 3

whoami=$(whoami)
sudo usermod -aG www-data $whoami
sudo usermod -a -G www-data $whoami

sudo find /var/web -type d -exec chmod 775 {} +
sudo find /var/web -type f -exec chmod 664 {} +
sudo chgrp www-data /var/web -R
sudo chmod g+w /var/web -R

sudo mkdir /var/log/yiimp
sudo touch /var/log/yiimp/debug.log
sudo chgrp www-data /var/log/yiimp -R
sudo chmod 775 /var/log/yiimp -R

sudo chgrp www-data /var/stratum -R
sudo chmod 775 /var/stratum

sudo mkdir -p /var/yiimp/sauv
sudo chgrp www-data /var/yiimp -R
sudo chmod 775 /var/yiimp -R

#Add to contrab screen-scrypt
(
    crontab -l 2>/dev/null
    echo "@reboot sleep 20 && /etc/screen-scrypt.sh"
) | crontab -
(
    crontab -l 2>/dev/null
    echo "@reboot sleep 20 && /etc/screen-stratum.sh"
) | crontab -

#fix error screen main "service"
sudo sed -i 's/service $webserver start/sudo service $webserver start/g' /var/web/yaamp/modules/thread/CronjobController.php
sudo sed -i 's/service nginx stop/sudo service nginx stop/g' /var/web/yaamp/modules/thread/CronjobController.php

#fix error screen main "backup sql frontend"
sudo sed -i "s|/root/backup|/var/yiimp/sauv|g" /var/web/yaamp/core/backend/system.php
#no need for Kudaraidee yiimp repo
#sudo sed -i '14d' /var/web/yaamp/defaultconfig.php

#Misc
sudo mkdir $HOME/yiimp-install-files
sudo mv $HOME/yiimp/ $HOME/yiimp-install-files
sudo mv $HOME/backup $HOME/yiimp-install-files
sudo rm -rf /var/log/nginx/*

#Hold update OpenSSL
#If you want remove the hold : sudo apt-mark unhold openssl
sudo apt-mark hold openssl

#Restart service
restart_service cron.service
restart_service mysql
sudo systemctl status mysql | sed -n "1,3p"
restart_service nginx.service
sudo systemctl status nginx | sed -n "1,3p"
restart_service php7.3-fpm.service
sudo systemctl status php7.3-fpm | sed -n "1,3p"

echo
echo -e "$GREEN Done$COL_RESET"
sleep 3

echo
install_end_message
echo
sudo rm -rf $HOME/yiimp_install_script
echo
