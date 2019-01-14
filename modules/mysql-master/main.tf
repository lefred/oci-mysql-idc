## DATASOURCE
# Init Script Files
data "template_file" "setup_mysql" {
  template = "${file("${path.module}/scripts/setup_replicate_master.sh")}"

  vars {
    mysql_repo_releasever = "${var.mysql_repo_releasever}"
    mysql_version         = "${var.mysql_version}"
    number_of_master      = "${var.number_of_master}"
    mysql_root_password   = "${var.mysql_root_password}"
    replicate_acount      = "${var.replicate_acount}"
    replicate_password    = "${var.replicate_password}"
  }
}

locals {
  setup_script_dest = "~/setup_replicate_master.sh"
}

## MYSQL REPLICATION MASTER INSTANCE
resource "oci_core_instance" "TFMysqlMaster" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}${var.master_display_name}"
  shape               = "${var.shape}"

  create_vnic_details {
    subnet_id        = "${var.subnet_id}"
    display_name     = "${var.label_prefix}${var.master_display_name}"
    assign_public_ip = "${var.assign_public_ip}"
    hostname_label   = "${var.master_display_name}"
  }

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id}"
    source_type = "image"
  }

  provisioner "file" {
    connection = {
      host        = "${self.private_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"

      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    content     = "${data.template_file.setup_mysql.rendered}"
    destination = "${local.setup_script_dest}"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${self.private_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"

      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    inline = [
      "chmod +x ${local.setup_script_dest}",
      "sudo ${local.setup_script_dest}",
    ]
  }

  timeouts {
    create = "10m"

    #create = "60m"
  }
}
