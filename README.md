<h1 align="center"> Yiimp Install Scrypt v0.4 (update 2022-08-01) 

<a href="https://discord.gg/GVZ4tchkKc"><img src="https://img.shields.io/discord/904564600354254898.svg?style=flat&label=Discord %3C3%20&color=7289DA%22" alt="Join Community Badge"/></a></h1>

 <h2 align="left"> :information_source: Yiimp install scrypt v0.4</h2>
Use this script on <b> fresh install ubuntu Server 16.04 / 18.04.</b> No other version is currently supported. This install script will get you 95% ready to go with yiimp. There are a few things you need to do after the main install is finished.
<h2 align="left"> ⚙️ The installer requires the following </h2>

* Fresh Ubuntu 16.04 or Ubuntu 18.04
* Minimum RAM 4GB.
* Recommended RAM 8GB or higher.

<h2 align="center"> 💾 Pre Installation. </h2>

Update and upgrade your system.
```
sudo apt-get update && sudo apt-get upgrade git -y
```
- Create your new user and add it to sudo group.
```
adduser pool
```
- Add the new user to the sudo group.
```
adduser pool sudo
```
- Now when you have add your new user to the sudo group, you need to reboot and then login to the new user.

### Clone the repository
- > Be sure you have su in to your pool user before you clone it, else you clone it to root user
```
sudo su pool
```
<h2 align="center"> 💾 To start the installation. </h2>
Just copy and past the command below and the install will start.

```
git clone https://github.com/afiniel/yiimp_install_script.git && bash $HOME/yiimp_install_script/install.sh
```

- It will take some time for the installation to be finnished.
- > If you have any issues with the installation open issue here on github.
***********************************

### :information_source: This script has an interactive beginning and will ask for the following information :

- Server Name (You can enter )(Example)): example.com or your ip of your vps like this 80.41.52.63)
- Are you using a subdomain: (subdomain.example.com)
- Enter support email:
- Set stratum to AutoExchange:
- Your Public IP for admin access: (Put your PERSONNAL IP, NOT IP of your VPS)
- Install Fail2ban:
- Install UFW and configure ports: 
- Install LetsEncrypt SSL: (Recommended)
* When you have answered all the questions the install will start.
***********************************

### Finish! Remember to 
```
sudo reboot
```
-  when the installer tell you to.

- Access your new pool at(SSL-Disabled): ```example.com/site/```  (SSL-Enabled) ```https://www.example.com/site/```
- Access AdminPanel(SSL-Disabled): ```example.com/site/AdminPanel``` (SSL-Enabled) ```https://www.example.com/site/AdminPanel```


### Update keys.php if you have exchange (Enable)

- > Update your public keys for exchanges (If Enable). update with Your own keys.. , you can find them in your exchange account.,
```
sudo nano /etc/yiimp/keys.php
```
### Change AdminRights

- > **If you want change your AdminRights to something else :** Edit this file "/SiteController.php" and Line 11 => change 'AdminPanel'

```
sudo nano /var/web/yaamp/modules/site/SiteController.php
```
###### :bangbang: **IMPORTANT** : 

- The configuration of yiimp and coin require a minimum of knowledge in linux
- Your mysql information (login/Password) is saved in **~/.my.cnf**

*****************************************************************************

While I did add some server security to the script, it is every server owners responsibility to fully secure their own servers. After the installation you will still need to customize your serverconfig.php file to your liking, add your API keys, and build/add your coins to the control panel.

## 🎁 Support

Donations for continued support of this script are welcomed at:

* BTC:  bc1q582gdvyp09038hp9n5sfdtp0plkx5x3yrhq05y
* Doge: DChLCc233BLxvzVRCtaR8pGCXGMuEFgUqD
* LTC:  ltc1qqw7cv4snx9ctmpcf25x26lphqluly4w6m073qw
* ETH: 0x50C7d0BF9714dBEcDc1aa6Ab0E72af8e6Ce3b0aB
