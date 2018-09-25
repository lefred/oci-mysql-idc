# OCI service
variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created."
}

variable "availability_domains" {
  description = "The Availability Domains of the slave instance."
  default     = []
}

variable "subnet_ids" {
  description = "List of Mysql slave subnets' id."
  default     = []
}

variable "slave_display_name" {
  description = "The name of the slave instance."
  default     = ""
}

variable "shape" {
  description = "Instance shape to use for slave instance. "
  default     = ""
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "number_of_slaves" {
  description = "The number of slave instance(s) to create."
}

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. Default 'true' assigns a public IP address."
  default     = true
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance."
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance."
  default     = ""
}

variable "image_id" {
  description = "The OCID of an image for an instance to use."
  default     = ""
}

# variable "master_public_ip" {
#   description = "Public IP of the Master Instance where the MySQL Master is installed."
# }

variable "master_private_ip" {
  description = "Private IP of the Master Instance where the MySQL Master is installed."
}

# variable "http_port" {
#   description = "The port to use for HTTP traffic to Mysql."
# }

variable "slaves_mysql_root_password" {
  description = "Password of the MySQL 'root@localhost' account in the Slave Instance."
}

variable "replicate_acount" {
  description = "Account on MySQL Master host to replicate binary logs from Master to Slaves."
}

variable "replicate_password" {
  description = "Password of the MySQL 'master_slaves_replicate_acount@%' account."
}

variable "bastion_host" {
  description = "The bastion host IP."
}

variable "bastion_user" {
  description = "The SSH user to connect to the bastion host."
  default     = "opc"
}

variable "bastion_private_key" {
  description = "The private key path to access the bastion host."
}
