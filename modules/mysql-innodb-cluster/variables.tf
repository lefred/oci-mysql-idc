variable "mysql_version" {
  description = "The version of the Mysql community server."
  default     = "8.0.32"
}

variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "availability_domains" {
  description = "The Availability Domain of the instance. "
  default     = []
}

variable "node_display_name" {
  description = "The name of the instance. "
  default     = ""
}

variable "subnet_id" {
  description = "The OCID of the subnet to create the VNIC in. "
  default     = ""
}

variable "node_shape" {
  description = "Instance shape to use for instance. "
  default     = "VM.Standard.E4.Flex"
}

variable "node_flex_shape_ocpus" {
  description = "Flex Instance shape OCPUs"
  default = 1
}

variable "node_flex_shape_memory" {
  description = "Flex Instance shape Memory (GB)"
  default = 6
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. Default 'false' do not assign a public IP address. "
  default     = false
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "image_id" {
  description = "The OCID of an image for an instance to use. "
  default     = ""
}

variable "vm_user" {
  description = "The SSH user to connect to the host."
  default     = "opc"
}

variable "bastion_ip" {
  description = "IP fo the bastion host"
}

variable "bastion_private_key" {
  description = "Bastion SSH Private Key"
}

variable "bastion_public_key" {
  description = "Bastion SSH Public Key"
}

variable "use_AD" {
  description = "Using different Availability Domain, by default use of Fault Domain"
  type        = bool
  default     = false
}

variable "number_of_nodes" {
  description = "Number of nodes in the cluster"
  default = 3
}

variable "clusteradmin_password" {
    description = "Password for the clusteradmin user able to connect from bastion/shell"
}

variable "cluster_name" {
  description = "MySQL InnoDB Cluster Name"
  default = "MyCluster"
}

locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex",
    "VM.Standard3.Flex",
    "VM.Standard4.Flex"
  ]
}

locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.node_shape)
}

