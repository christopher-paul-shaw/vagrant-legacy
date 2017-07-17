#! /usr/bin/env bash

###
#
# install.sh
#
# This script assumes your Vagrantfile has been configured to map the root of
# your application to /vagrant and that your web root is the "public" folder
# (Laravel standard).  Standard and error output is sent to
# /vagrant/vm_build.log during provisioning.
#
###

# Variables
DBHOST=localhost
DBNAME=dbname
DBUSER=dbuser
DBPASSWD=test123

PHPVER=5


echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

echo -e "\n--- Install VIM ---\n"
apt-get -y install vim

echo -e "\n--- Install base packages ---\n"
apt-get -y install vim curl build-essential python-software-properties git /vagrant/vm_build.log 2>&1

echo -e "\n--- Add Node 6.x rather than 4 ---\n"
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

echo -e "\n--- Install MySQL specific packages and settings ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /vagrant/vm_build.log 2>&1
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'" > /vagrant/vm_build.log 2>&1

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php$PHPVER apache2 libapache2-mod-php$PHPVER php$PHPVER-curl php$PHPVER-gd php$PHPVER-mysql php-gettext >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Installing Composer for PHP package management ---\n"
curl --silent https://getcomposer.org/installer | php >> /vagrant/vm_build.log 2>&1
mv composer.phar /usr/local/bin/composer

echo -e "\n--- Installing NodeJS and NPM ---\n"
apt-get -y install nodejs >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Installing javascript components ---\n"
npm install -g gulp bower >> /vagrant/vm_build.log 2>&1

