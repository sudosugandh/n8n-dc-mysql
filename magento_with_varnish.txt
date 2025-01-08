# Magento 2 Setup on Debian 12 with LEMP Stack, Redis, and Varnish

## System Overview
- **OS**: Debian 12
- **Server**: LEMP Stack
- **Cache/Cache DB**: Varnish/Redis

---

## 1. Update and Install MySQL Server
```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo wget https://dev.mysql.com/get/mysql-apt-config_0.8.32-1_all.deb
sudo apt install gnupg
sudo dpkg -i mysql-apt-config_0.8.32-1_all.deb
sudo apt update
sudo apt install mysql-server -y
sudo systemctl restart mysql
---
Configure Database
mysql -u root -p 
CREATE DATABASE db;
CREATE USER 'magento'@'localhost' IDENTIFIED BY 'm2n1shlko';
GRANT ALL PRIVILEGES ON db.* TO 'magento'@'localhost';
GRANT SUPER ON *.* TO 'magento'@'localhost';
---
2. Install Elasticsearch
 cd /opt/
 wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.1-amd64.deb
 dpkg -i elasticsearch-7.6.1-amd64.deb
 curl -XGET 'http://localhost:9200'
---
3. Install PHP, PHP-FPM, and Tune php.ini
 sudo apt install lsb-release ca-certificates apt-transport-https -y
 sudo curl -sSL https://packages.sury.org/php/README.txt | sudo bash -
 sudo apt install php8.1-fpm php8.1-common php8.1-mysql php8.1-gmp php8.1-curl php8.1-soap php8.1-intl php8.1-mbstring php8.1-xmlrpc 
  php8.1-gd php8.1-xml php8.1-cli php8.1-zip php8.1-bcmath -y

Update /etc/php/8.1/fpm/php.ini
 file_uploads = On
 allow_url_fopen = On
 short_open_tag = On
 memory_limit = 256M
 cgi.fix_pathinfo = 0
 zlib.output_compression = On
 upload_max_filesize = 128M
 max_execution_time = 600
 max_input_time = 900
 date.timezone = America/Chicago
---
4. Configure Nginx VirtualHost for Magento
 sudo nano /etc/nginx/sites-available/test.mgt.com.conf

Content:
upstream fastcgi_backend {
    server unix:/run/php/php8.1-fpm.sock;
}
server {
    server_name test.mgt.com;
    listen 80;
    set $MAGE_ROOT /var/www/ecommerce;
    include /var/www/ecommerce/nginx.conf.sample;
}
---
5. Install Magento 2
 sudo mkdir -p /var/www/ecommerce
 git clone https://github.com/magento/magento2.git /var/www/ecommerce/
 curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
 cd /var/www/ecommerce
 composer install --ignore-platform-reqs
---
Run Magento Installation
 bin/magento setup:install \
    --base-url=http://test.mgt.com \
    --db-host=localhost --db-name=db \
    --db-user=magento --db-password=m2n1shlko \
    --admin-firstname=FirstName --admin-lastname=LastName \
    --admin-email=your@emailaddress.com \
    --admin-user=magentoadmin --admin-password=m2n1shlko \
    --language=en_US --currency=USD --timezone=America/Chicago --use-rewrites=1
---
Update Admin URI (Optional)
Edit app/etc/env.php:

'frontName' => 'admin'
---
6. Set File Permissions
 chown -R www-data:www-data /var/www/ecommerce/
 find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
 find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
 chmod -R 777 var pub
---
7. Enable HTTPS with Self-Signed SSL
 Generate SSL Certificate
 sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt
 sudo openssl dhparam -out /etc/nginx/dhparam.pem 2048
---
Configure Nginx for HTTPS
Add the following block to /etc/nginx/sites-available/test.mgt.com.conf:

server {
    listen 443 ssl;
    include snippets/self-signed.conf;
    include snippets/ssl-params.conf;

    set $MAGE_ROOT /var/www/ecommerce;
    include /var/www/ecommerce/nginx.conf.sample;
}
---
8. Install and Configure Redis
 sudo apt install redis-server -y
 sudo systemctl start redis
 sudo systemctl enable redis
---
Update Magento Cache Configuration
bin/magento setup:config:set \
    --cache-backend=redis \
    --cache-backend-redis-server=127.0.0.1 \
    --cache-backend-redis-db=1 \
    --skip-db-validation
---
9. Configure Varnish Cache
 Install Varnish
sudo apt install varnish -y
---
Update Varnish Configuration
Edit /etc/systemd/system/varnish.service:
ExecStart=/usr/sbin/varnishd -a :80 ...

Edit /etc/varnish/default.vcl:
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}
---
10. Finalize Setup
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento cache:flush
---
Visit your site at:
































