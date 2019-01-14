# This is an example of how to use the terraform_oci_mysql module to deploy a MySQL cluster in Oracle Cloud Infrastructure by using
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
module "mysql-replication-set" {
  source                           = "../../"
  compartment_ocid                 = "${var.compartment_ocid}"
  master_ad                        = "${data.template_file.ad_names.*.rendered[0]}"
  master_subnet_id                 = "${var.master_subnet_id}"
  master_image_id                  = "${var.image_id[var.region]}"
  master_mysql_root_password       = "${var.master_mysql_root_password}"
  master_slaves_replicate_acount   = "${var.master_slaves_replicate_acount}"
  master_slaves_replicate_password = "${var.master_slaves_replicate_password}"

  slave_ads                  = "${data.template_file.ad_names.*.rendered}"
  slave_subnet_ids           = "${var.slave_subnet_ids}"
  slave_image_id             = "${var.image_id[var.region]}"
  ssh_authorized_keys        = "${var.ssh_authorized_keys}"
  ssh_private_key            = "${var.ssh_private_key}"
  slaves_mysql_root_password = "${var.slaves_mysql_root_password}"
  replicate_master_count     = "${var.replicate_master_count}"
  replicate_slave_count      = "${var.replicate_slave_count}"
  bastion_host               = "${var.bastion_host}"
  bastion_user               = "${var.bastion_user}"
  bastion_private_key        = "${var.bastion_private_key}"
}
