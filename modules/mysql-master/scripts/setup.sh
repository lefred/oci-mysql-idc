#!/bin/bash
set -e -x

#mysql_root_password="Admin@123"
#http_port=3306
#number_of_master=1
#replicate_acount="repl"
#replicate_password="Slaves@123"
#master_mysql_status=

function forceToKillMysqld() {
  MYSQLDID=`ps -ef | grep "mysqld" | grep -v "opc" | awk '{print $2}'`
  echo "In the forceToKillMysqld function."
  if [ $MYSQLDID ]; then
    for id in $MYSQLDID
    do
      if [ $id ]; then
        sudo kill -9 $id
        echo "killed $id"
      fi
    done
  else
    echo "Mysqld has been stop by the mysqladmin command."
  fi
}

# Get the status of MySQL Master. File name and position in status will be used to initialize the Slave instance.
function getMasterStatus() {
  master_mysql_status=$(mysql -uroot -p${mysql_root_password} -s -e "show master status \G;")
  command sudo echo $master_mysql_status >/tmp/master_mysql_status
}

# Install Mysql
# Using Latest version： https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
sudo wget -O /etc/yum.repos.d/mysql.rpm https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
cd /etc/yum.repos.d
sudo rpm -Uvh mysql.rpm

sudo yum install -y mysql-community-server

# Set httpport on firewall
sudo firewall-cmd --zone=public --permanent --add-port=${http_port}/tcp
sudo firewall-cmd --reload

#At the initial start-up of the server, the server is initializeda superuser
#and account’root’@’localhost’ is created, when MySQL data directory is empty.
sudo systemctl start mysqld.service
sudo systemctl status mysqld.service
sudo systemctl stop mysqld.service
echo "MySQL installed successfully!"

#Add user mysql in my.cnf to modify generated temporary password of 'root@localhose'
sudo chmod 666 /etc/my.cnf
command sudo cat >>/etc/my.cnf <<'EOF'

user=mysql
EOF
sudo chmod 644 /etc/my.cnf

#Make a temporary file to save the mysql alter user statement
sudo echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_password}';" >/tmp/passfile

#Modify the root temporary password with a user-specified password
sudo chown mysql /var/run/mysqld
sudo mysqld --user=mysql --init-file=/tmp/passfile &
sleep 5
sudo mysqladmin -u root -p${mysql_root_password} shutdown
sleep 5

PSCOUNTER=`ps -ef | grep "mysqld" | wc -l`
if [ $PSCOUNTER -ge 2 ]; then
  echo "The number of Mysqld active thread is $PSCOUNTER"
  forceToKillMysqld
fi

while [ -f /tmp/passfile ]; do
  sudo rm /tmp/passfile
done

#sudo systemctl status mysqld.service

#Config my.cnf on MySQL Server Master INSTANCE
#server-id should be an Integer number between 1 and 2^32 – 1
#server-id should be different from any other server-ids in the same MySQL cluster
sudo chmod 666 /etc/my.cnf
command sudo cat >>/etc/my.cnf <<'EOF'

server-id=1
log-bin=MysqlMaster
auto_increment_offset=1
EOF
command sudo echo "auto_increment_increment=${number_of_master}" >>/etc/my.cnf
sudo chmod 644 /etc/my.cnf

#Start mysql service
sudo systemctl start mysqld.service
echo "MySQL started successfully."
#waitForMysql

#Execute the MySQL statement
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
