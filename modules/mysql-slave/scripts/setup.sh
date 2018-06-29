#!/bin/bash
set -e -x

#mysql_root_password="Admin@123"
#http_port=3306
#replicate_acount="repl"
#replicate_password="Slaves@123"
#master_public_ip="129.146.169.130"
#mysql_server_id=$1

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

function getMysqlMasterStatus() {
  sudo chmod 0600 /tmp/key.pem
  ssh -oStrictHostKeyChecking=no -i /tmp/key.pem opc@${master_public_ip} 'sudo cat /tmp/master_mysql_status' > /tmp/status
  sleep 3
  mysqlstatus=$(sudo cat /tmp/status)
  #echo "$mysqlstatus" | awk -F ":" '{print $2}'
  delimeter1=':'
  temp1=`echo $mysqlstatus | cut -d "$delimeter1" -f 2`
  temp2=`echo $mysqlstatus | cut -d "$delimeter1" -f 3`
  delimeter2=' '
  master_log_filename=`echo $temp1 | cut -d "$delimeter2" -f 1`
  master_log_fileposition=`echo $temp2 | cut -d "$delimeter2" -f 1`

  while [ -f /tmp/key.pem ]; do
    sudo rm /tmp/key.pem
  done
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
  forceToKillMysqld
fi

while [ -f /tmp/passfile ]; do
  sudo rm /tmp/passfile
done

#Connect to MySQL Master Host to get MySQL Status Infromation.
getMysqlMasterStatus
if [ $master_log_filename ]&&[ $master_log_fileposition ]; then
  echo "MySQl Master Status infromation(File and Postion):"
  echo $master_log_filename
  echo $master_log_fileposition
else
  echo "Error: Can not get MySQL Master Status. Can not get status file"
fi

#Config my.cnf on MySQL Slave to connect with the Master
#server-id should be an Integer number between 1 and 2^32 – 1
#server-id should be different from any other server-ids in the same MySQL cluster.
#---------Attention---------
#In this program, the server-id of the Mysql Slave will begin with 3001
sudo chmod 666 /etc/my.cnf

command sudo echo "server-id=$1" >>/etc/my.cnf
sudo chmod 644 /etc/my.cnf

#Start mysql service
sudo systemctl start mysqld.service
echo "MySQL started successfully."
#waitForMysql

mysql -uroot -p${mysql_root_password} <<EOF
stop slave;
EOF

mysql -uroot -p${mysql_root_password} -e "change master to master_host='${master_public_ip}', master_user='${replicate_acount}', master_password='${replicate_password}',master_log_file='$master_log_filename',master_log_pos=$master_log_fileposition;"
mysql -uroot -p${mysql_root_password} <<EOF
start slave;
EOF

sleep 5

mysql -u ${replicate_acount} -h ${master_public_ip} -p${replicate_password} -s -e "exit"
if [ $? -ne 0 ]; then
    echo "Failed! MySQL Slave can not connect to Master. Please check your network."
else
    echo "Succeed! MySQL Slave can connect to Master"
fi

sleep 5

mysql -uroot -p${mysql_root_password} <<EOF
show slave status \G;
EOF
