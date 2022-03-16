#!/bin/bash

# Update repos
sudo apt update

# Do full upgrade of system
sudo apt full-upgrade -y

# Remove leftover packages and purge configs
sudo apt autoremove -y --purge

# Install required packages
sudo apt install -y ufw rabbitmq-server

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

# Add admin user
sudo rabbitmqctl add_user stonx_admin 7Fa6QR33Rcpc99HR
sudo rabbitmqctl set_user_tags stonx_admin administrator
sudo rabbitmqctl set_permissions -p / stonx_admin ".*" ".*" ".*"

# Delete default guest user
sudo rabbitmqctl delete_user guest

# Add vhosts
sudo rabbitmqctl add_vhost webserver
sudo rabbitmqctl set_permissions -p webserver stonx_admin ".*" ".*" ".*"

# Add db user
sudo rabbitmqctl add_user db stonx_mariadb
sudo rabbitmqctl set_permissions -p webserver db ".*" ".*" ".*"

# Add webserver user
sudo rabbitmqctl add_user webserver stonx_websrv
sudo rabbitmqctl set_permissions -p webserver webserver ".*" ".*" ".*"
