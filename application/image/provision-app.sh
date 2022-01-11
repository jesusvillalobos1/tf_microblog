#!/usr/bin/bash
# Script to install and test the Flask Microblog project on a VirtualBox machine.
# For local testing pruposes.
# This script should be migrated to Ansible or Puppet

# Install required packages:

apt-get -qq update
apt-get -qq install -y python3 python3-venv python3-dev
#Fix postfix install
apt-get -y install mysql-server supervisor nginx git
debconf-set-selections <<< "postfix postfix/mailname string bigproject.name"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get -qq install --assume-yes postfix

#Enable local firewall
apt-get install -y ufw
ufw allow ssh
ufw allow http
ufw allow 443/tcp
ufw --force enable
echo "Dependencies installed" 

# Adding depoy user
adduser deploy --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo deploy:deploy2022! | chpasswd
echo "deploy user created"

# Commands that need to run as deploy
sudo -i -u deploy bash << EOF
cd /home/deploy
git clone https://github.com/miguelgrinberg/microblog; cd microblog; git checkout v0.17
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn pymysql cryptography
echo "export FLASK_APP=microblog.py" >> ~/.profile
EOF

SECRET_KEY=$(python3 -c "import uuid; print(uuid.uuid4().hex)")
touch .env
echo "SECRET_KEY=${SECRET_KEY}" >> .env
##for local
echo "MAIL_SERVER=localhost" >> .env
echo "MAIL_PORT=25" >> .env
echo "DATABASE_URL=mysql+pymysql://microblog:microdbpwd@localhost:3306/microblog" >> .env
mv .env /home/deploy/microblog/.env; chown deploy:deploy /home/deploy/microblog/.env

touch /etc/supervisor/conf.d/microblog.conf
cat > /etc/supervisor/conf.d/microblog.conf <<'EOF'
[program:microblog]
command=/home/deploy/microblog/venv/bin/gunicorn -b localhost:8000 -w 4 microblog:app
directory=/home/deploy/microblog
user=deploy
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
EOF

mkdir /home/deploy/certs
cp /vagrant/certs/*.pem /home/deploy/certs/
chown -R deploy:deploy /home/deploy/certs/
rm /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-enabled/microblog <<'EOF'
server {
    # listen on port 80 (http)

    listen 80;
    server_name _;
    location / {
        # redirect any requests to the same URL but on https

        return 301 https://$host$request_uri;
    }
}
server {
    # listen on port 443 (https)

    listen 443 ssl;
    server_name _;

    # location of the self-signed SSL certificate

    ssl_certificate /home/deploy/certs/cert.pem;
    ssl_certificate_key /home/deploy/certs/key.pem;

    # write access and error logs to /var/log

    access_log /var/log/microblog_access.log;
    error_log /var/log/microblog_error.log;

    location / {
        # forward application requests to the gunicorn server

        proxy_pass http://localhost:8000;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /static {
        # handle static files directly, without forwarding to the application
        alias /home/deploy/microblog/app/static;
        expires 30d;
    }
}
EOF

# Configure MYSQL.
systemctl stop mysql
systemctl set-environment MYSQLD_OPTS="--skip-networking --skip-grant-tables"
systemctl start mysql.service
mysql -u root << EOF
flush privileges;
use mysql;
ALTER USER  'root'@'localhost' IDENTIFIED BY 'P4ssw0rd';
EOF
systemctl restart mysql.service

mysql -u root -pP4ssw0rd << EOF
create database microblog character set utf8 collate utf8_bin;
create user 'microblog'@'localhost' identified by 'microdbpwd';
grant all privileges on microblog.* to 'microblog'@'localhost';
flush privileges;
EOF 

sudo -i -u deploy bash << EOF
flask translate compile
flask db upgrade
EOF

systemctl restart nginx.service
systemctl enable nginx.service
service supervisor reload