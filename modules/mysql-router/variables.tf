variable "mysql_version" {
  description = "The version of the Mysql community server."
  default     = "8.0.32"
}


variable "ssh_private_key" {
  description = "The private key to access instance. "
  default     = ""
}

variable "vm_user" {
  description = "The SSH user to connect to the host."
  default     = "opc"
}

variable "primary_ip" {
  description = "IP of the Primary Instance."
  default     = ""
}

variable "mysql_shell_ip" {
  description = "IP of the MySQL Shell."
  default     = ""
}

variable "clusteradmin_password" {
    description = "Password for the clusteradmin user able to connect from bastion/shell"
}
