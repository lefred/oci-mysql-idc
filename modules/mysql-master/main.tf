## DATASOURCE
# Init Script Files
locals {
  master_mysql_status = ""
}

data "template_file" "setup_mysql" {
  template = "${file("${path.module}/scripts/setup.sh")}"

  vars {
    http_port           = "${var.http_port}"
    number_of_master    = "${var.number_of_master}"
    mysql_root_password = "${var.mysql_root_password}"
    replicate_acount    = "${var.replicate_acount}"
    replicate_password  = "${var.replicate_password}"

    #master_mysql_status = "${local.master_mysql_status}"
  }
}

## MYSQL MASTER INSTANCE
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
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${data.template_file.setup_mysql.rendered}"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }

  timeouts {
    #create = "10m"
    create = "60m"
  }
}
