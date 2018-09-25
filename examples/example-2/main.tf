resource "oci_core_instance" "bastion" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.bastion_display_name}${var.bastion_ad_index+1}"
  shape               = "${var.bastion_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.bastion.id}"
    assign_public_ip = true
  }

  metadata {
    ssh_authorized_keys = "${file("${var.bastion_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id[var.region]}"
    source_type = "image"
  }
}

# DEPLOY THE MYSQL REPLICATION CLUSTER
module "mysql-replication-set" {
  source           = "../../"
  compartment_ocid = "${var.compartment_ocid}"
  master_ad        = "${data.template_file.ad_names.*.rendered[0]}"
  master_subnet_id = "${oci_core_subnet.MysqlMasterSubnetAD.id}"
  master_image_id  = "${var.image_id[var.region]}"

  #slave_count         = "2"
  replicate_master_count = "${var.replicate_master_count}"
  replicate_slave_count  = "${var.replicate_slave_count}"

  master_mysql_root_password       = "${var.master_mysql_root_password}"
  master_slaves_replicate_acount   = "${var.master_slaves_replicate_acount}"
  master_slaves_replicate_password = "${var.master_slaves_replicate_password}"
  slaves_mysql_root_password       = "${var.slaves_mysql_root_password}"

  slave_ads           = "${data.template_file.ad_names.*.rendered}"
  slave_subnet_ids    = "${split(",",join(",", oci_core_subnet.MysqlSlaveSubnetAD.*.id))}"
  slave_image_id      = "${var.image_id[var.region]}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"

  bastion_host        = "${oci_core_instance.bastion.public_ip}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"

  #http_port = "3306"
  #master_count                     = "1"
}
