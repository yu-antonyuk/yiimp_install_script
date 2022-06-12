# Yiimp_install_scrypt (update 2022-06-12)<a href="https://discord.gg/GVZ4tchkKc"><img src="https://img.shields.io/discord/904564600354254898.svg?style=flat&label=Discord %3C3%20&color=7289DA%22" alt="Join Community Badge"/></a>

[Afiniel-Website](https://www.afiniel.xyz/)  

### Forks used.
[Yiimp](https://github.com/Kudaraidee/yiimp.git)

[Orginal-Installer](https://github.com/cryptopool-builders/multipool_original_yiimp_installer)


###

## Install script for yiimp on Ubuntu Server 16.04 / 18.04

Use this script on fresh install ubuntu Server 16.04 / 18.04. ``` No other version is currently supported. ``` This install script will get you 95% ready to go with yiimp. There are a few things you need to do after the main install is finished.

Connect on your VPS =>

```
git clone https://github.com/afiniel/yiimp_install_script.git
```
### cd to the installer map.
```
cd yiimp_install_script
```

### Now just execute update-and-create-user.sh
⚠️ REMEMBER the script create user with pool as name, if you want to change it ⚠️
```
sudo nano update-and-create-user.sh
```

### If you dont mind it will be named pool just countinue.
```
bash update-and-create-user.sh
```
### Now it's time to start the installation.
```
bash install.sh
```

Finish !
- Go http://xxx.xxx.xxx.xxx or https://xxx.xxx.xxx.xxx (if you have chosen LetsEncrypt SSL). Enjoy !
- Go http://xxx.xxx.xxx.xxx/site/myadmin or https://xxx.xxx.xxx.xxx/site/myadmin to access Panel Admin

If you are issue after installation (nginx,mariadb... not found), use this script : bash install-debug.sh (watch the log during installation)


###### :bangbang: **YOU MUST UPDATE THE FOLLOWING FILES :**
- **/var/web/serverconfig.php :** update this file to include your public ip (line = YAAMP_ADMIN_IP) to access the admin panel (Put your PERSONNAL IP, NOT IP of your VPS). update with public keys from exchanges. update with other information specific to your server..
- **/etc/yiimp/keys.php :** update with secrect keys from the exchanges (not mandatory)
- **If you want change 'AdminPanel' to access Panel Admin :** Edit this file "/var/web/yaamp/modules/site/SiteController.php" and Line 11 => change 'AdminPanel'


###### :bangbang: **IMPORTANT** : 

- The configuration of yiimp and coin require a minimum of knowledge in linux
- Your mysql information (login/Password) is saved in **~/.my.cnf**

***********************************

###### This script has an interactive beginning and will ask for the following information :

- Server Name (no http:// or www !!!!! Example : crypto.com OR pool.crypto.com OR 80.41.52.63)
- Are you using a subdomain (mypoolx11.crypto.com)
- Enter support email
- Set stratum to AutoExchange
- Your Public IP for admin access (Put your PERSONNAL IP, NOT IP of your VPS)
- Install Fail2ban
- Install UFW and configure ports
- Install LetsEncrypt SSL

***********************************

While I did add some server security to the script, it is every server owners responsibility to fully secure their own servers. After the installation you will still need to customize your serverconfig.php file to your liking, add your API keys, and build/add your coins to the control panel. 

There will be several wallets already in yiimp. These have nothing to do with the installation script and are from the database import from the yiimp github.
