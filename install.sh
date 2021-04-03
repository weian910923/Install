#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
### 更新套件
yum update -y
yum install epel-release -y
yum install yum-utils -y
### 設定時區
timedatectl set-timezone Asia/Taipei
### 安裝 nginx 
yum install nginx -y
### 安裝 php7.4
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php74

yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-fpm -y
yum install -y  php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-apc php-bcmath 
yum install -y  php-gearman php-intl php-mbstring php-memcache php-uuid php-opcache php-memcached php-redis php-fpm
yum -y install php-xml

##修改php.conf
vi /etc/php-fpm.d/www.conf
# 修改以下參數
user = nginx
group = nginx
listen = /var/run/php-fpm/php-fpm.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0666

##啟動php-fpm,nginx
systemctl start php-fpm;systemctl start nginx
systemctl status php-fpm;systemctl status nginx

##########查看虛擬機 ip 綁定本機 /etc/hosts
ip a
sudo vi /etc/hosts














