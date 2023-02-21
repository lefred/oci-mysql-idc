# oci-mysql-idc

These are Terraform modules that deploy [MySQL](https://www.mysql.com/) on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/en_US/cloud-infrastructure).

## About
The MySQL Oracle Cloud Infrastructure Module provides a Terraform-based MySQL InnoDB Cluster installation for Oracle Cloud Infrastructure.

The default setup is composed by one bastion host orchestrating the cluster using MySQL Shell and having MySQL Router bootsrapped, and a MySQL InnoDB Cluster of 3 members.

Members can be installed on different Availability Domains or Fault Domains.

![MySQL InnoDB Cluster architecture](https://github.com/lefred/oci-mysql/raw/innodbcluster/examples/multiple_fd/images/oci_multi_fd.png)

## Prerequisites

* Download and install Terraform (v0.12.21 or later)
* Download and install the Oracle Cloud Infrastructure Terraform Provider (v2.0.0 or later)


## What's a Module?
A Module is a canonical, reusable, best-practices definition for how to run a single piece of infrastructure, such as a database or server cluster. Each Module is created using Terraform, and includes automated tests, examples, and documentation. It is maintained both by the open source community and companies that provide commercial support.
Instead of figuring out the details of how to run a piece of infrastructure from scratch, you can reuse existing code that has been proven in production. And instead of maintaining all that infrastructure code yourself, you can leverage the work of the Module community to pick up infrastructure improvements through a version number bump.

## How to use this Module
Each Module has the following folder structure:
* [root](.): This folder contains a root module calls  mysql-innodb-cluster, mysql-router and mysql-shellsub-modules to create a MySQL InnoDB cluster in Oracle Cloud Infrastructure.
* [modules](modules): This folder contains the reusable code for this Module, broken down into one or more modules.
* [examples](examples): This folder contains examples of how to use the modules.

The following code shows how to deploy MySQL InnoDB Cluster using this module:

```
module "mysql-shell" {
  source              = "./modules/mysql-shell"
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  compartment_ocid    = "${var.compartment_ocid}"
  display_name        = "MySQLShellBastion"
  image_id            = var.node_image_id == "" ? "${data.oci_core_images.images_for_shape.images[0].id}" : "${var.node_image_id}"
  shape               = "${var.node_shape}"
  label_prefix        = "${var.label_prefix}"
  subnet_id           = "${oci_core_subnet.public.id}"
  ssh_authorized_keys = var.ssh_authorized_keys_path == "" ? tls_private_key.public_private_key_pair.public_key_openssh : file("${var.ssh_authorized_keys_path}")
  ssh_private_key     = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file("${var.ssh_private_key_path}")
  bastion_private_key = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file("${var.ssh_private_key_path}")
}

module "mysql-innodb-cluster" {
  number_of_nodes       = "${var.number_of_nodes}"
  source                = "./modules/mysql-innodb-cluster"
  availability_domains  = "${data.template_file.ad_names.*.rendered}"
  compartment_ocid      = "${var.compartment_ocid}"
  node_display_name     = "${var.node_display_name}"
  image_id              = var.node_image_id == "" ? "${data.oci_core_images.images_for_shape.images[0].id}" : "${var.node_image_id}"
  shape                 = "${var.node_shape}"
  label_prefix          = "${var.label_prefix}"
  subnet_id             = "${oci_core_subnet.private.id}"
  cluster_name          = "${var.cluster_name}"
  clusteradmin_password = "${var.clusteradmin_password}"
  ssh_authorized_keys   = var.ssh_authorized_keys_path == "" ? tls_private_key.public_private_key_pair.public_key_openssh : file("${var.ssh_authorized_keys_path}")
  ssh_private_key       = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file("${var.ssh_private_key_path}")
  bastion_private_key   = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file("${var.ssh_private_key_path}")
  bastion_public_key    = var.ssh_authorized_keys_path == "" ? tls_private_key.public_private_key_pair.public_key_openssh : file("${var.ssh_authorized_keys_path}")
  bastion_ip            = var.bastion_host == null ? "${module.mysql-shell.public_ip}" : "${var.bastion_host}"
}

module "mysql-router" {
  source                = "./modules/mysql-router"
  ssh_private_key       = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file("${var.ssh_private_key_path}")
  mysql_shell_ip        = "${module.mysql-shell.public_ip}"
  clusteradmin_password = "${var.clusteradmin_password}"
  primary_ip            = "${module.mysql-innodb-cluster.private_ip}"
}
```


Argument | Description
--- | ---
compartment_ocid | Compartment's OCID where VCN will be created.
label_prefix | To create unique identifier for multiple clusters in a compartment.
tenancy_ocid | description = "Tenancy's OCID"
user_ocid | description = "User's OCID"
region | OCI Region
vcn | VCN Name [default: mysql_vcn]
vcn_cidr | VCN's CIDR IP Block [default: 10.0.0.0/16]
fingerprint | Key Fingerprint
dns_label | Allows assignment of DNS hostname when launching an Instance. 
label_prefix | To create unique identifier for multiple clusters in a compartment.
ssh_authorized_keys | Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. 
ssh_private_key | The private key path to access instance. 
private_key_path | The private key path to pem. 
node_display_name | The name of a MySQL InnoDB Cluster instance. [default: MySQLInnoDBClusterNode]
node_shape | Instance shape to use for Primary instance. [default: VM.Standard.E4.Flex]
mysql_root_password | Password of the MySQL 'root@localhost' account.
bastion_host | IP fo the bastion host [default: null]
use_AD | Using different Availability Domain, by default use of Fault Domain [default: false]
number_of_nodes | Number of nodes in the cluster [default: 3]
clusteradmin_password | Password for the clusteradmin user able to connect from bastion/shell
cluster_name | MySQL InnoDB Cluster Name [default: MyCluster]

