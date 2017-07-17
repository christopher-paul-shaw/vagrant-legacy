#! /usr/bin/env bash

# Variables
DBHOST=localhost
DBNAME=dbname
DBUSER=dbuser
DBPASSWD=test123
PHPVER=5

echo -e "\n--- Updating ---\n"
apt-get -qq update
apt-get -y install vim curl mysql mysql-server build-essential python-software-properties git >> /vagrant/vm_build.log 2>&1
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - >> /vagrant/vm_build.log 2>&1
apt-get -qq update
echo -e "\nComplete!\n"

echo -e "\n--- Setting up MySQL ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server phpmyadmin >> /vagrant/vm_build.log 2>&1
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /vagrant/vm_build.log 2>&1
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'" > /vagrant/vm_build.log 2>&1
echo -e "\nComplete!\n"

echo -e "\n--- Setting Up Apache && PHP ---\n"
apt-get -y install php$PHPVER apache2 libapache2-mod-php$PHPVER php$PHPVER-curl php$PHPVER-gd php$PHPVER-mysql php-gettext >> /vagrant/vm_build.log 2>&1
a2enmod rewrite >> /vagrant/vm_build.log 2>&1
> /etc/apache2/sites-enabled/000-default.conf
echo "
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:80>
    ServerName www.evolutionfunding.app
    ServerAlias evolutionfunding.app
    DocumentRoot /var/www/evolutionfunding.app/main/

    RewriteEngine On
    RewriteCond %{HTTP_HOST} !^www\.evolutionfunding\.app [NC]
    RewriteRule ^(.*)$ http://www.evolutionfunding.app$1 [R=301,L]

    SetEnv URL_BASE www.evolutionfunding.app
    SetEnv APPLICATION_BASE /var/www.evolutionfunding.app/main/
    SetEnv APPLICATION_ENV development

    <Directory /var/www/www.evolutionfunding.app/main/ >
        Options +ExecCGI -Indexes
        AllowOverride All
    </Directory>
</VirtualHost>
" >> /etc/apache2/sites-enabled/000-default.conf
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
service apache2 restart >> /vagrant/vm_build.log 2>&1

echo -e "\n--- Installing Extras (Composer,NodeJS,ect) ---\n"
curl --silent https://getcomposer.org/installer | php >> /vagrant/vm_build.log 2>&1
mv composer.phar /usr/local/bin/composer
apt-get -y install nodejs >> /vagrant/vm_build.log 2>&1
npm install -g gulp bower >> /vagrant/vm_build.log 2>&1
