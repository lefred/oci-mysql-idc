#!/bin/bash
#set -x

rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
yum install -y mysql-router-community-${mysql_version}  --refresh

echo "MySQL Router installed successfully!"

echo ${clusteradmin_password} | mysqlrouter --bootstrap clusteradmin@${primary_ip}:3306 --conf-use-gr-notifications --user mysqlrouter --force 
sed -i '/auth_cache_refresh_interval=2/c\auth_cache_refresh_interval=60' /etc/mysqlrouter/mysqlrouter.conf

echo "MySQL Router bootstrapped successfully!"

firewall-cmd --zone=public --add-port=6446/tcp --permanent
firewall-cmd --zone=public --add-port=6447/tcp --permanent
firewall-cmd --zone=public --add-port=64460/tcp --permanent
firewall-cmd --zone=public --add-port=64470/tcp --permanent
firewall-cmd --zone=public --add-port=8443/tcp --permanent
firewall-cmd --reload

echo "Local Firewall updated"

systemctl start mysqlrouter >/dev/null 2>&1
if [[ $? -eq 0 ]]
then
    echo "MySQL Router is running..."
fi
