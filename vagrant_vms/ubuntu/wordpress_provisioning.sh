#!/bin/bash
#this script is used to provision an Ubuntu machine with the necessary dependencies for wordpress setup
set -e

echo "updating packages and installing dependencies"
apt-get update -y
apt-get upgrade -y
apt-get install -y wget unzip curl
#installation of apache2
echo "installing apache2"
apt-get install -y apache2
#installation of mariadb
echo "installing mariadb"
apt-get install -y mariadb-server mariadb-client
#installation of php 
echo "installing php and necessary extensions"
apt-get install -y php php-mysql libapache2-mod-php php-cli
#enabling apache and mariadb
echo "enabling apache2 and mariadb"
systemctl enable apache2
systemctl start apache2
systemctl enable mariadb
systemctl start mariadb

# Secure MariaDB non-interactively
echo "Securing MariaDB"

# Wait for MariaDB to be fully ready
while ! mysqladmin ping -h localhost --silent; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
done

echo "Securing MariaDB"
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('rootpassword');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF

echo "Creating WordPress database and user"
mysql -u root -prootpassword <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wp_user'@'localhost' IDENTIFIED BY 'wppassword';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EOF

cd /tmp
echo "downloading wordpress"
wget -q https://wordpress.org/latest.zip
echo "unzipping wordpress"
unzip -q latest.zip -d /tmp
rm -rf /var/www/html/index.html

echo "Deploying WordPress to /var/www/html/wordpress"
mkdir -p /var/www/html/wordpress
cp -R /tmp/wordpress/* /var/www/html/wordpress/
chown -R www-data:www-data /var/www/html/wordpress/
chmod -R 755 /var/www/html/wordpress/
mkdir -p /var/www/html/wordpress/wp-content/uploads
chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads
chmod -R 755 /var/www/html/wordpress/wp-content/uploads
systemctl restart apache2

echo "provisioning complete!!!!!

