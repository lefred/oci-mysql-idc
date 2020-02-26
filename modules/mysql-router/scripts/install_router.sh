#!/bin/bash
#set -x

rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum install -y mysql-router-community-${mysql_version} 

echo "MySQL Router installed successfully!"

mysqlrouter --bootstrap clusteradmin:${clusteradmin_password}@${primary_ip}:3306 --conf-use-gr-notifications --user mysqlrouter --force

echo "MySQL Router bootstrapped successfully!"

firewall-cmd --zone=public --add-port=6446/tcp --permanent
firewall-cmd --zone=public --add-port=6447/tcp --permanent
firewall-cmd --zone=public --add-port=64460/tcp --permanent
firewall-cmd --zone=public --add-port=64470/tcp --permanent
firewall-cmd --reload

echo "Local Firewall updated"

systemctl start mysqlrouter >/dev/null 2>&1
if [[ $? -eq 0 ]]
then
    echo "MySQL Router is running..."
fi
