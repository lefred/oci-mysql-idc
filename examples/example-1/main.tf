# This is an example of how to use the terraform_oci_mysql module to deploy a MySQL cluster in OCI by using
# existing VCN, Security list and Subnets.

# PROVIDER
provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

# DATASOURCE
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}

# DEPLOY THE MYSQL CLUSTER
module "mysql" {
  source                           = "../../"
  compartment_ocid                 = "${var.compartment_ocid}"
  master_ad                        = "${data.template_file.ad_names.*.rendered[0]}"
  master_subnet_id                 = "${var.master_subnet_id}"
  master_image_id                  = "${var.image_id[var.region]}"
  http_port                        = "3306"
  master_mysql_root_password       = "${var.master_mysql_root_password}"
  master_slaves_replicate_acount   = "${var.master_slaves_replicate_acount}"
  master_slaves_replicate_password = "${var.master_slaves_replicate_password}"
  master_count                     = "1"

  slave_count                = "2"
  slave_ads                  = "${data.template_file.ad_names.*.rendered}"
  slave_subnet_ids           = "${var.slave_subnet_ids}"
  slave_image_id             = "${var.image_id[var.region]}"
  ssh_authorized_keys        = "${var.ssh_authorized_keys}"
  ssh_private_key            = "${var.ssh_private_key}"
  slaves_mysql_root_password = "${var.slaves_mysql_root_password}"
}

# VARIABLES
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}
variable "master_subnet_id" {}

variable "master_mysql_root_password" {}
variable "slaves_mysql_root_password" {}
variable "master_slaves_replicate_acount" {}
variable "master_slaves_replicate_password" {}

variable "slave_subnet_ids" {
  type = "list"
}

variable "image_id" {
  type = "map"

  # Oracle-provided image "Oracle-Linux-7.5-2018.06.14-0"
  # See https://docs.us-phoenix-1.oraclecloud.com/images/
  default = {
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaxyc7rpmh3v4yyuxcdjndofxuuus4iwd7a7wjc63u2ykycojr5djq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaazq7xlunevyn3cf4wppcx2j53eb26pnnc4ukqtfj4tbjjcklnhpaa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7qdjjqlvryzxx4i2zs5si53edgmwr2ldn22whv5wv34fc3sdsova"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaas5vonrmseff5fljdmpffffqotcqdrxkbsctotrmqfrnbjd6wwsfq"
  }
}
