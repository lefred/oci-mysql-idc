variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "dns_label" {
  description = "Allows assignment of DNS hostname when launching an Instance. "
  default     = ""
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "master_ad" {
  description = "The Availability Domain for MySQL master. "
  default     = ""
}

variable "master_subnet_id" {
  description = "The OCID of the master subnet to create the VNIC in. "
  default     = ""
}

variable "master_display_name" {
  description = "The name of the master instance. "
  default     = "tf-mysql-master"
}

variable "master_image_id" {
  description = "The OCID of an image for a master instance to use. "
  default     = ""
}

variable "master_shape" {
  description = "Instance shape to use for master instance. "
  default     = "VM.Standard1.1"
}

variable "master_mysql_root_password" {
  description = "Password of the MySQL 'root@localhost' account in the Master Instance."
  default     = ""
}

variable "master_slaves_replicate_acount" {
  description = "Account on MySQL Master host to replicate binary logs from Master to Slaves."
  default     = ""
}

variable "master_slaves_replicate_password" {
  description = "Password of the MySQL 'master_slaves_replicate_acount@%' account."
  default     = ""
}

variable "master_user_data" {
  description = "Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration for master instance. "
  default     = ""
}

variable "replicate_master_count" {
  description = "Number of master instances to launch. "

  #default     = 1
}

variable "replicate_slave_count" {
  description = "Number of slave instances to launch. "

  #default     = 2
}

variable "slave_ads" {
  description = "The Availability Domain(s) for MySQL slave(s). "
  default     = []
}

variable "slave_subnet_ids" {
  description = "List of MySQL slave subnets' id. "
  default     = []
}

variable "slave_display_name" {
  description = "The name of the slave instance. "
  default     = "tf-mysql-slave"
}

variable "slave_image_id" {
  description = "The OCID of an image for slave instance to use.  "
  default     = ""
}

variable "slave_shape" {
  description = "Instance shape to use for slave instance. "
  default     = "VM.Standard1.1"
}

variable "slave_user_data" {
  description = "Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration for slave instance. "
  default     = ""
}

# variable "http_port" {
#   description = "The port to use for HTTP traffic to MySQL. "
#   default     = 3306
# }

variable "slaves_mysql_root_password" {
  description = "Password of the MySQL 'root@localhost' account in the Slaves Instance."
  default     = ""
}
