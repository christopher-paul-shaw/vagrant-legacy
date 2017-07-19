#! /usr/bin/env bash

# Variables
DBHOST=localhost
DBNAME=dbname
DBUSER=dbuser
DBPASSWD=test123

echo "[ Provisioning machine ]"
echo "1) Update APT..."
apt-get -qq update

echo "1) Install Utilities..."
apt-get install -y tidy pdftk curl xpdf imagemagick openssl vim git

echo "2) Installing Apache..."
apt-get install -y apache2

echo "3) Installing PHP and packages..."
apt-get install -y php5 libapache2-mod-php5 libssh2-php php-pear php5-cli php5-common php5-curl php5-dev php5-gd php5-imagick php5-imap php5-intl php5-mcrypt php5-memcached php5-mysql php5-pspell php5-xdebug php5-xmlrpc
#php5-suhosin-extension, php5-mysqlnd

echo "4) Installing MySQL..."
debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"
apt-get install -y mysql-server
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

echo "5) Generating self signed certificate..."
mkdir -p /etc/ssl/localcerts
openssl req -new -x509 -days 365 -nodes -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -out /etc/ssl/localcerts/apache.pem -keyout /etc/ssl/localcerts/apache.key
chmod 600 /etc/ssl/localcerts/apache*

echo "6) Setup Apache..."
a2enmod rewrite
> /etc/apache2/sites-enabled/000-default.conf
echo "
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

" >> /etc/apache2/sites-enabled/000-default.conf
service apache2 restart 

echo "7) Composer Install..."
curl --silent https://getcomposer.org/installer | php 
mv composer.phar /usr/local/bin/composer

echo "8) Install NodeJS..."
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - 
apt-get -qq update
apt-get -y install nodejs 

echo "9) Install NPM Packages..."
npm install -g gulp gulp-cli

echo "Provisioning Completed"