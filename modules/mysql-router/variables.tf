variable "mysql_version" {
  description = "The version of the Mysql community server."
  default     = "8.0.21"
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "vm_user" {
  description = "The SSH user to connect to the master host."
  default     = "opc"
}

variable "primary_ip" {
  description = "IP of the Primary Master."
  default     = ""
}

variable "mysql_shell_ip" {
  description = "IP of the MySQL Shell."
  default     = ""
}


variable "clusteradmin_password" {
    description = "Password for the clusteradmin user able to connect from bastion/shell"
}
