#!/bin/bash
#set -x

# Install Mysql
## Using the MySQL Yum repository to install the latest versions of MySQL 8.0
## Install Latest version： https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
##sudo wget -O /etc/yum.repos.d/mysql.rpm https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
##cd /etc/yum.repos.d
##sudo rpm -Uvh mysql.rpm
##sudo yum install -y mysql-community-server

# Install MySQL Community Edition 8.0
rpm -ivh https://dev.mysql.com/get/mysql80-community-release-$(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/')-1.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
yum install -y mysql-shell-${mysql_version} 
mkdir ~${user}/.mysqlsh
cp /usr/share/mysqlsh/prompt/prompt_256pl+aw.json ~${user}/.mysqlsh/prompt.json
echo '{
    "history.autoSave": "true",
    "history.maxSize": "5000"
}' > ~${user}/.mysqlsh/options.json
chown -R ${user} ~${user}/.mysqlsh

echo "MySQL Shell successfully!"
