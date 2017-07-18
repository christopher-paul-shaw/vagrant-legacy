#! /usr/bin/env bash

# Variables
DBHOST=localhost
DBNAME=dbname
DBUSER=dbuser
DBPASSWD=test123
PHPVER=5

echo -e "--- Updating ---\n"
apt-get -qq update
apt-get -y install vim curl build-essential python-software-properties git 
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - 
apt-get -qq update
echo -e "--- Setting up MySQL ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

echo -e "--- Setting Up Apache && PHP ---\n"
apt-get -y install apache2 tidy pdftk zbarimg xpdf pdftotext imagemagick libssh2-php php-pear php5 php5-cli php5-common php5-curl php5-dev php5-gd php5-imagick php5-imap php5-intl php5-mcrypt php5-memcached php5-mysql php5-mysqlnd php5-pspell php5-suhosin-extension php5-xdebug php5-xmlrpc

a2enmod rewrite
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
service apache2 restart 

echo -e "\n--- Installing Extras (Composer,NodeJS,ect) ---\n"
curl --silent https://getcomposer.org/installer | php 
mv composer.phar /usr/local/bin/composer
apt-get -y install nodejs 
npm install -g gulp gulp-cli
