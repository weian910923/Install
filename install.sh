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
yum -y install php-xml php-mbstring 
yum install php-cli php-zip wget unzip -y

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
### 打開網頁 10.xx.xx.xx

##########查看 phpinfo
cd /home;chmod 755 vagrant/;vi index.php
##
#<?php
#phpinfo();
#?>
##
##重啟php-fpm,nginx
systemctl restart php-fpm;systemctl restart nginx

### 安裝 mysql,phpmyadmin
yum install mariadb-server mariadb -y
systemctl start mariadb;systemctl enable  mariadb
## mysql 初始化
mysql_secure_installation

cd /tmp/;wget https://files.phpmyadmin.net/phpMyAdmin/4.4.9/phpMyAdmin-4.4.9-all-languages.tar.gz
cd /tmp/;tar zxvf phpMyAdmin-4.4.9-all-languages.tar.gz -C /usr/share/nginx/html/
cd /usr/share/nginx/html;mv phpMyAdmin-4.4.9-all-languages phpMyAdmin
cd /usr/share/nginx/html/phpMyAdmin/;cp config.sample.inc.php config.inc.php

cd /etc/nginx/conf.d/;vi phpmyadmin.conf

cd /var/lib/php;chmod -R 777 session
vi /etc/php.ini;error_reporting = 〜E_DEPRECATED＆E_ALL

systemctl restart nginx;systemctl restart php-fpm

### 安裝 composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
cp /usr/local/bin/composer /usr/bin/
composer -v

### laravel 專案
cd /home/vagrant/
composer global require laravel/installer
composer create-project --prefer-dist laravel/laravel blog "5.8.*"

cd /home/vagrant/blog;chmod -R 777 storage
cd /home/vagrant/blog/bootstrap;chmod -R 777 cache;
cd /home/vagrant/blog/;php artisan

cat > /etc/nginx/conf.d/blog.conf <<EOF
server {
    listen 80;
    server_name "blog.com";

    root /home/vagrant/blog/public/;

    access_log /var/log/nginx/blog.access.log;
    error_log  /var/log/nginx/blog.error.log;

    client_header_buffer_size 16k;
    large_client_header_buffers 4 32k;
    index  index.php index.html index.htm;

    location / {
        try_files  $uri /index.php?$query_string;
    }

    location ~ \.php$ {
      fastcgi_index  index.php;
      fastcgi_pass   unix:/var/run/php-fpm/php-fpm.sock;
      fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include        fastcgi_params;
    }
}

EOF





















