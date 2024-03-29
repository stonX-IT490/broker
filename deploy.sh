#!/bin/bash

# Ask user for RabbitMQ Admin Password
read -s -p "Set password for stonx_admin RabbitMQ user: " rmq_admin_password
echo -e '\n'

# Update repos
sudo -i apt update

# Do full upgrade of system
sudo apt full-upgrade -y

# Remove leftover packages and purge configs
sudo apt autoremove -y --purge

# Install required packages
sudo apt install -y ufw rabbitmq-server wget unzip php-bcmath php-amqp php-curl php-cli php-zip php-mbstring inotify-tools

# Setup firewall
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 5672/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Install zerotier
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -s https://install.zerotier.com | sudo bash

# Enable rabbitmq management plugin
sudo rabbitmq-plugins enable rabbitmq_management

# Install rabbitmqadmin
wget http://127.0.0.1:15672/cli/rabbitmqadmin

# Add admin user
sudo rabbitmqctl stop_app
sudo rabbitmqctl reset
sudo rabbitmqctl start_app
sudo rabbitmqctl add_user stonx_admin $rmq_admin_password
sudo rabbitmqctl set_user_tags stonx_admin administrator
sudo rabbitmqctl set_permissions -p / stonx_admin ".*" ".*" ".*"

# Delete default guest user
sudo rabbitmqctl delete_user guest

# Add vhosts
sudo rabbitmqctl add_vhost webHost
sudo rabbitmqctl set_permissions -p webHost stonx_admin ".*" ".*" ".*"
sudo rabbitmqctl add_vhost dmzHost
sudo rabbitmqctl set_permissions -p dmzHost stonx_admin ".*" ".*" ".*"
sudo rabbitmqctl add_vhost webDmzHost
sudo rabbitmqctl set_permissions -p webDmzHost stonx_admin ".*" ".*" ".*"
sudo rabbitmqctl add_vhost pushHost
sudo rabbitmqctl set_permissions -p pushHost stonx_admin ".*" ".*" ".*"
sudo rabbitmqctl add_vhost logHost
sudo rabbitmqctl set_permissions -p logHost stonx_admin ".*" ".*" ".*"

# Add db user
sudo rabbitmqctl add_user db stonx_mariadb
sudo rabbitmqctl set_permissions -p webHost db ".*" ".*" ".*"
sudo rabbitmqctl set_permissions -p dmzHost db ".*" ".*" ".*"
sudo rabbitmqctl set_permissions -p pushHost db ".*" ".*" ".*"

# Add webserver user
sudo rabbitmqctl add_user webserver stonx_websrv
sudo rabbitmqctl set_permissions -p webHost webserver ".*" ".*" ".*"
sudo rabbitmqctl set_permissions -p webDmzHost webserver ".*" ".*" ".*"

# Add dmz user
sudo rabbitmqctl add_user dmz stonx_dmz
sudo rabbitmqctl set_permissions -p dmzHost dmz ".*" ".*" ".*"
sudo rabbitmqctl set_permissions -p webDmzHost dmz ".*" ".*" ".*"
sudo rabbitmqctl set_permissions -p pushHost dmz ".*" ".*" ".*"

# Add logging user
sudo rabbitmqctl add_user log stonx_log
sudo rabbitmqctl set_permissions -p logHost log ".*" ".*" ".*"

# Declare Queue # deprecated with new rabbitMQLib
# sudo rabbitmqadmin -u stonx_admin -p $rmq_admin_password declare queue --vhost=webHost name=webserver durable=true
# sudo rabbitmqadmin -u stonx_admin -p $rmq_admin_password declare queue --vhost=dmzHost name=dmz durable=true
# sudo rabbitmqadmin -u stonx_admin -p $rmq_admin_password declare queue --vhost=pushHost name=push durable=true
# sudo rabbitmqadmin -u stonx_admin -p $rmq_admin_password declare queue --vhost=webDmzHost name=news durable=true

# Setup Central Logging
git clone git@github.com:stonX-IT490/logging.git ~/logging
cd ~/logging
git pull
chmod +x deploy.sh
./deploy.sh
cd ~/
