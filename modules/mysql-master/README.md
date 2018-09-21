## Create compute instance, setup MySQL and configure it as master node
This module creates a compute instance in Oracle Cloud Infrastructure, then use setup.sh to setup and configure MySQL as master node. After the mysql installation is complete, we need to change the generated, temporary password and set a custom password for the root account to proceed to the next step. The password entered here is "master_mysql_root_password" specified by the customer in the terraform.tfvars.template file.


### Input of this module
Argument | Description
--- | ---
http_port | The port to use for HTTP traffic to MySQL.
master_mysql_root_password | The password of MySQL 'root' account on the master instance.
master_slaves_replicate_acount | The mysql account that will be used for replication between the master instance and the slave instances.
master_slaves_replicate_password | Password of the mysql replication account.

### Output of this module  
Argument | Description
--- | ---
id | ID of this mysql master instance.
public_ip | Public ip of this instance, it will be used to communicate with the mysql slave instances.
private_ip | Private ip of this instance.
master_host_names | Host name of this instance.
