#/bin/bash

echo "Updating system"
apt-get -qq update
apt-get -yqqf upgrade

# MySQL
MYSQL_PASSWORD=avocado # TODO: make this not suck
command -v mysql > /dev/null
if [ $? -ne 0 ]; then
    echo "Installing MySQL"
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
    apt-get -yqq install mysql-server mysql-client libmysqlclient-dev
fi
echo "Dropping possibly out-of-date MySQL development database"
mysqladmin --password=$MYSQL_PASSWORD -u root -f drop development
echo "Loading MySQL development database"
mysqladmin --password=$MYSQL_PASSWORD -u root -f create development
#mysql --password=$MYSQL_PASSWORD -u root development < /vagrant/config/dev_dump.sql

# Git
command -v git > /dev/null
if [ $? -ne 0 ]; then
    echo "Installing Git"
    apt-get -yqq install git
fi

# Python/Pip
echo "Installing Pip"
apt-get install -y  python
apt-get install -y  python-dev
apt-get install -y  python-pip

# Vim
echo "Installing Vim"
apt-get install -y  vim

# Pip packages
echo "Installing requirements.txt"
pip install -r /vagrant/config/requirements.txt