#!/bin/bash
set -e -x

#number_of_master=1
#mysql_root_password="Admin@123"
#replicate_acount="repl"
#replicate_password="Slave@123"

# Get the status of MySQL Master. File name and position in status will be used to initialize the Slave instance.
function getMasterStatus() {
  master_mysql_status=$(mysql -uroot -p${mysql_root_password} -s -e "show master status \G;")
  command sudo echo $master_mysql_status >/home/opc/master_mysql_status
}

# Install Mysql
# Using Latest version： https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
sudo wget -O /etc/yum.repos.d/mysql.rpm https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
cd /etc/yum.repos.d
sudo rpm -Uvh mysql.rpm

sudo yum install -y mysql-community-server

# Set httpport on firewall
sudo firewall-cmd --zone=public --permanent --add-port=3306/tcp
sudo firewall-cmd --reload

# At the initial start-up of the server, the server is initializeda superuser
# and account’root’@’localhost’ is created, when MySQL data directory is empty.
sudo systemctl start mysqld.service
sudo systemctl status mysqld.service

echo "MySQL installed successfully!"

# Add skip-grant-tables parameter for mysql to alter password
sudo chmod 666 /etc/my.cnf
command sudo cat >>/etc/my.cnf <<'EOF'

skip-grant-tables
EOF
sudo chmod 644 /etc/my.cnf

# Restart mysql service
sudo systemctl restart mysqld.service

# Alter password for root
mysql <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Admin@1235';
EOF

# Stop mysql service
sudo systemctl stop mysqld.service

# Delete the added skip-grant-tables parameter in my.cnf
sudo sed -i '$d' /etc/my.cnf

# Set replication parameters
sudo chmod 666 /etc/my.cnf
command sudo cat >>/etc/my.cnf <<'EOF'

server-id=1
log-bin=MysqlMaster
auto_increment_offset=1
EOF
command sudo echo "auto_increment_increment=${number_of_master}" >>/etc/my.cnf
sudo chmod 644 /etc/my.cnf

# Start mysql service
sudo systemctl start mysqld.service
echo "MySQL started successfully."

# Alter the password of root to the user-specified password
mysql -uroot -pAdmin@1235 -e "SET sql_log_bin=OFF;"
mysql -uroot -pAdmin@1235 -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_password}';"
mysql -uroot -p${mysql_root_password} -e "SET sql_log_bin=ON;"

# Execute the MySQL statement
mysql -uroot -p${mysql_root_password} -e "CREATE USER '${replicate_acount}'@'%' IDENTIFIED BY '${replicate_password}';"
mysql -uroot -p${mysql_root_password} -e "GRANT REPLICATION SLAVE ON *.* TO '${replicate_acount}'@'%';"
mysql -uroot -p${mysql_root_password} -e "show grants for '${replicate_acount}'@'%';"
mysql -uroot -p${mysql_root_password} <<EOF
flush privileges;
EOF
sleep 5

# Get MySQL Master status.
#The file name and position will be used in the Slave instances.
getMasterStatus
