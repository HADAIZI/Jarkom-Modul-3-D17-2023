# testing 15-17
ab -n 100 -c 10 -p register.json -T application/json http://10.30.4.1:8001/api/auth/register
ab -n 100 -c 10 -p register.json -T application/json http://10.30.4.1:8001/api/auth/login

curl -X POST -H "Content-Type: application/json" -d @register.json http://10.30.4.1:8001/api/auth/login > login.txt
token=$(cat login.txt | jq -r '.token')
ab -n 100 -c 10 -H "Authorization: Bearer $token" http://10.30.4.1:8001/api/me

# client
# khusus richter tambah ini karena fixed echo nameserver 192.168.122.1 >> /etc/resolv.conf
apt-get update
apt-get install dnsutils -y
apt-get install lynx -y
apt-get install apache2-utils -y

# tambahan client kiri
echo '
{
    "username": "kelompokd17",
    "password": "passwordd17"
}
' > /root/register.json

apt-get install jq -y

# benchmarking ke target ip LB
ab -n 1000 -c 100 http://10.30.2.2/
ab -n 1000 -c 100 http://granz.channel.d17.com/

# client ip from dhcp config
echo '
auto eth0
iface eth0 inet dhcp
hwaddress ether hwaddress
' > /etc/network/interfaces

# script db (denken)
apt-get update
apt-get install mariadb-server -y
service mysql start

mysql <<EOF
CREATE USER 'kelompokd17'@'%' IDENTIFIED BY 'passwordd17';
CREATE USER 'kelompokd17'@'localhost' IDENTIFIED BY 'passwordd17';
CREATE DATABASE dbkelompokd17;
GRANT ALL PRIVILEGES ON *.* TO 'kelompokd17'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'kelompokd17'@'localhost';
FLUSH PRIVILEGES;
EOF

echo '
[client-server]

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/

[mysqld]
skip-networking=0
skip-bind-address
' > /etc/mysql/my.cnf

echo '
[server]

[mysqld]

user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
socket                  = /run/mysqld/mysqld.sock
#port                   = 3306
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql
#skip-external-locking

# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
bind-address            = 0.0.0.0

query_cache_size        = 16M

log_error = /var/log/mysql/error.log

expire_logs_days        = 10

character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci

[embedded]

[mariadb]

[mariadb-10.3]
' > /etc/mysql/mariadb.conf.d/50-server.cnf

service mysql restart

# script laravel worker 
apt-get update

apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2

curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg

sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

apt-get update

apt-get install php8.0-mbstring php8.0-xml php8.0-cli php8.0-common php8.0-intl php8.0-opcache php8.0-readline php8.0-mysql php8.0-fpm php8.0-curl unzip wget -y

apt-get install nginx -y

wget https://getcomposer.org/download/2.0.13/composer.phar

chmod +x composer.phar

mv composer.phar /usr/bin/composer

apt-get install --reinstall tzdata

apt-get install git -y

cd /var/www

git clone https://github.com/martuafernando/laravel-praktikum-jarkom.git

cd laravel-praktikum-jarkom

composer update
composer install

cd /var/www/laravel-praktikum-jarkom

cp .env.example .env

echo '
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=10.30.2.1
DB_PORT=3306
DB_DATABASE=dbkelompokd17
DB_USERNAME=kelompokd17
DB_PASSWORD=passwordd17

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
' > /var/www/laravel-praktikum-jarkom/.env

php artisan key:generate
php artisan config:cache
php artisan migrate:fresh
php artisan db:seed
php artisan storage:link
php artisan jwt:secret
php artisan config:clear

echo '
server {

    listen 8001;

    root /var/www/laravel-praktikum-jarkom/public;

    index index.php index.html index.htm;
    server_name riegel.canyon.d17.com;

    location / {
            try_files $uri $uri/ /index.php?$query_string;
    }

    # pass PHP scripts to FastCGI server
    location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
    }

    location ~ /\.ht {
            deny all;
    }

    error_log /var/log/nginx/implementasi_error.log;
    access_log /var/log/nginx/implementasi_access.log;
}
' > /etc/nginx/sites-available/riegel.canyon.d17

ln -s /etc/nginx/sites-available/riegel.canyon.d17 /etc/nginx/sites-enabled/

chown -R www-data.www-data /var/www/laravel-praktikum-jarkom/storage

service php8.0-fpm start
service nginx start

apt-get install lynx -y

# Tambahan Fern
echo '[www]
user = www-data
group = www-data
listen = /run/php/php8.0-fpm.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

; Choose how the process manager will control the number of child processes.

pm = dynamic
pm.max_children = 10
pm.start_servers = 3
pm.min_spare_servers = 1
pm.max_spare_servers = 5
' > /etc/php/8.0/fpm/pool.d/www.conf

service php8.0-fpm restart

# Tambahan Flamme
echo '[www]
user = www-data
group = www-data
listen = /run/php/php8.0-fpm.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

; Choose how the process manager will control the number of child processes.

pm = dynamic
pm.max_children = 15
pm.start_servers = 5
pm.min_spare_servers = 4
pm.max_spare_servers = 8
' > /etc/php/8.0/fpm/pool.d/www.conf

service php8.0-fpm restart

# Tambahkan Frieren
echo '[www]
user = www-data
group = www-data
listen = /run/php/php8.0-fpm.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

; Choose how the process manager will control the number of child processes.

pm = dynamic
pm.max_children = 25
pm.start_servers = 12
pm.min_spare_servers = 8 
pm.max_spare_servers = 15
' > /etc/php/8.0/fpm/pool.d/www.conf

service php8.0-fpm restart

service php8.0-fpm restart
# Tambahan Flamme

# script php worker (kalau apache)
apt-get update
apt-get install php -y
apt-get install apache2 -y
apt-get install libapache2-mod-php7.3
apt-get install wget -y
apt-get install unzip -y
apt-get install htop -y

service apache2 start

mkdir /var/www/granz.channel.d17

wget -O /var/www/granz.channel.d17/granz.channel.yyy.com.zip "https://drive.google.com/u/0/uc?id=1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1&export=download"

unzip -d /var/www/granz.channel.d17 /var/www/granz.channel.d17/granz.channel.yyy.com.zip && rm /var/www/granz.channel.d17/granz.channel.yyy.com.zip

mv /var/www/granz.channel.d17/modul-3/css /var/www/granz.channel.d17
mv /var/www/granz.channel.d17/modul-3/js /var/www/granz.channel.d17
mv /var/www/granz.channel.d17/modul-3/index.php /var/www/granz.channel.d17
mv /var/www/granz.channel.d17/modul-3/info.php /var/www/granz.channel.d17

rm -r /var/www/granz.channel.d17/modul-3

touch /etc/apache2/sites-available/granz.channel.d17.com.conf

echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/granz.channel.d17
        ServerName granz.channel.d17.com

        <Directory /var/www/granz.channel.d17>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
 
</VirtualHost>
' > /etc/apache2/sites-available/granz.channel.d17.com.conf

a2ensite granz.channel.d17.com
service apache2 restart

# script php worker (nginx)
apt-get update
apt-get install nginx -y
apt-get install php php-fpm -y
apt-get install wget -y
apt-get install unzip -y
apt-get install htop -y

mkdir /var/www/granz.channel.d17

wget -O /var/www/granz.channel.d17/granz.channel.yyy.com.zip "https://drive.google.com/u/0/uc?id=1ViSkRq7SmwZgdK64eRbr5Fm1EGCTPrU1&export=download"

unzip -d /var/www/granz.channel.d17 /var/www/granz.channel.d17/granz.channel.yyy.com.zip && rm /var/www/granz.channel.d17/granz.channel.yyy.com.zip

mv /var/www/granz.channel.d17/modul-3/css /var/www/granz.channel.d17
mv /var/www/granz.channel.d17/modul-3/js /var/www/granz.channel.d17
mv /var/www/granz.channel.d17/modul-3/index.php /var/www/granz.channel.d17
mv /var/www/granz.channel.d17/modul-3/info.php /var/www/granz.channel.d17

rm -r /var/www/granz.channel.d17/modul-3

touch /etc/nginx/sites-available/granz.channel.d17

echo '
server {
    listen 80;

    root /var/www/granz.channel.d17;

    index index.php index.html index.htm;
    server_name granz.channel.d17.com;

    location / {
                    try_files $uri $uri/ /index.php?$query_string;
    }

    # pass PHP scripts to FastCGI server
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
    }

    location ~ /\.ht {
                    deny all;
    }

    error_log /var/log/nginx/granz_channel_d17.log;
    access_log /var/log/nginx/granz_channel_d17.log;
}
' > /etc/nginx/sites-available/granz.channel.d17

ln -s /etc/nginx/sites-available/granz.channel.d17 /etc/nginx/sites-enabled

rm -rf /etc/nginx/sites-enabled/default
 
service nginx restart
service php7.3-fpm start
service php7.3-fpm restart

# script load balancer (Eisen)
apt-get update
apt-get install nginx -y
apt-get install htop -y
service nginx start

touch /etc/nginx/sites-available/lb-granz
mkdir /etc/nginx/rahasiakita

echo '
netics:$apr1$sWc7lqUh$WZtJIOErQKS/ydaCV46ft1
' > /etc/nginx/rahasiakita/.htpasswd

echo '
# Default menggunakan Round Robin
upstream backend  {
    server 10.30.3.1; # IP Lugner
    server 10.30.3.2; # IP Linie
    server 10.30.3.3; # IP Lawine
}
 
server {
    listen 80;
    server_name granz.channel.d17.com;

    location / {
        allow 10.30.3.69;
        allow 10.30.3.70;
        allow 10.30.4.167;
        allow 10.30.4.168;
        proxy_pass http://backend;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    Host $http_host;

        auth_basic "Administrator'/'''s Area";
        auth_basic_user_file /etc/nginx/rahasiakita/.htpasswd;
    }

    location ~ /\.ht {
        deny all;
    }

    location /its {
        allow 10.30.3.69;
        allow 10.30.3.70;
        allow 10.30.4.167;
        allow 10.30.4.168;
        proxy_pass https://www.its.ac.id;
    }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;
}
' > /etc/nginx/sites-available/lb-granz

echo '
# Default menggunakan Round Robin
upstream backend-laravel  {
    server 10.30.4.1:8001; # IP Fern
    server 10.30.4.2:8002; # IP Flamme
    server 10.30.4.3:8003; # IP Frieren
}
 
server {
    listen 81;
    server_name riegel.canyon.d17.com;

    location / 
        proxy_bind 10.30.2.2;

        proxy_pass http://backend;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    Host $http_host;

    }

    error_log /var/log/nginx/lb_error.log;
    access_log /var/log/nginx/lb_access.log;
}
' > /etc/nginx/sites-available/lb-riegel

ln -s /etc/nginx/sites-available/lb-granz /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/lb-riegel /etc/nginx/sites-enabled
rm -rf /etc/nginx/sites-enabled/default
service nginx restart

# script dhcp server (Himmel)
apt update
apt install isc-dhcp-server -y

echo '
INTERFACESv4="eth0"
INTERFACESv6=""
' > /etc/default/isc-dhcp-server

echo '
subnet 10.30.1.0 netmask 255.255.255.0 {
}
subnet 10.30.2.0 netmask 255.255.255.0 {
    option routers 10.30.2.0;
    option broadcast-address 10.30.2.255;
    option domain-name-servers 10.30.1.2;
}
subnet 10.30.3.0 netmask 255.255.255.0 {
    range 10.30.3.16 10.30.3.32;
    range 10.30.3.64 10.30.3.80;
    option routers 10.30.3.0;
    option broadcast-address 10.30.3.255;
    option domain-name-servers 10.30.1.2;
    default-lease-time 180;
    max-lease-time 5760;
}

subnet 10.30.4.0 netmask 255.255.255.0 {
    range 10.30.4.12 10.30.4.20;
    range 10.30.4.160 10.30.4.168;
    option routers 10.30.4.0;
    option broadcast-address 10.30.4.255;
    option domain-name-servers 10.30.1.2;
    default-lease-time 720;
    max-lease-time 5760;
}

host Lugner {
    hardware ethernet a2:9e:52:b8:ec:7c; 
    fixed-address 10.30.3.1;
}

host Linie {
    hardware ethernet 36:33:94:64:ef:cc; 
    fixed-address 10.30.3.2;
}

host Lawine {
    hardware ethernet a2:eb:f1:be:9b:65;
    fixed-address 10.30.3.3;
}

host Fern {
    hardware ethernet a2:d9:1e:52:fd:ff;
    fixed-address 10.30.4.1;
}

host Flamme {
    hardware ethernet 4e:2d:5c:c8:e6:80;
    fixed-address 10.30.4.2;
}

host Frieren {
    hardware ethernet 16:8c:a3:19:91:3b;
    fixed-address 10.30.4.3;
}

host Denken {
    hardware ethernet 2a:b9:20:f6:fd:c9;
    fixed-address 10.30.2.1;
}

host Eisen {
    hardware ethernet a6:06:02:c2:28:a4;
    fixed-address 10.30.2.2;
}

' > /etc/dhcp/dhcpd.conf

service isc-dhcp-server stop
service isc-dhcp-server start

# netconf node dhcp
echo '
auto eth0
iface eth0 inet dhcp
hwaddress ether hwaddress
' > /etc/network/interfaces

# script dhcp relay (Aura)
apt-get update
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start

echo '
SERVERS="10.30.1.1"
INTERFACES="eth1 eth2 eth3 eth4"
OPTIONS=""
' > /etc/default/isc-dhcp-relay

echo '
net.ipv4.ip_forward=1
' > /etc/sysctl.conf

service isc-dhcp-relay restart
# script dns server (Heiter)
apt-get update
apt-get install bind9 -y

echo '
zone "riegel.canyon.d17.com" {
       type master;
       file "/etc/bind/jarkom/riegel.canyon.d17.com";
};

zone "granz.channel.d17.com" {
    type master;
    file "/etc/bind/jarkom/granz.channel.d17.com";
};

zone "3.30.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/3.30.10.in-addr.arpa";
};

' > /etc/bind/named.conf.local

mkdir /etc/bind/jarkom

cp /etc/bind/db.local /etc/bind/jarkom/riegel.canyon.d17.com
cp /etc/bind/db.local /etc/bind/jarkom/granz.channel.d17.com

echo '
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     riegel.canyon.d17.com. root.riegel.canyon.d17.com. (
                     2022100601         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      riegel.canyon.d17.com.
@       IN      A       10.30.4.1       ; IP Node Fern
www     IN      CNAME   riegel.canyon.d17.com.
@       IN      AAAA    ::1
' > /etc/bind/jarkom/riegel.canyon.d17.com

echo '
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     granz.channel.d17.com. root.granz.channel.d17.com. (
                     2022100601         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      granz.channel.d17.com.
@       IN      A       10.30.3.1       ; IP Node Lugner
www     IN      CNAME   granz.channel.d17.com.
@       IN      AAAA    ::1
' > /etc/bind/jarkom/granz.channel.d17.com

cp /etc/bind/db.local /etc/bind/jarkom/3.30.10.in-addr.arpa

echo '
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     granz.channel.d17.com. root.granz.channel.d17.com. (
                     2022100601         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
3.30.10.in-addr.arpa.   IN      NS      granz.channel.d17.com.
1                       IN      PTR     granz.channel.d17.com.  ; Byte ke-4 Lugner
' > /etc/bind/jarkom/3.30.10.in-addr.arpa

echo '
options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };

    allow-query{any;};
    auth-nxdomain no;       # conform to RFC1035
    listen-on-v6 { any; };
};
' > /etc/bind/named.conf.options
service bind9 restart