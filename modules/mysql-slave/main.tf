## DATASOURCE
# Init Script Files
data "template_file" "install_slave" {
  template = "${file("${path.module}/scripts/setup_replicate_slave.sh")}"

  vars {
    master_public_ip = "${var.master_public_ip}"

    #http_port           = "${var.http_port}"
    mysql_root_password = "${var.slaves_mysql_root_password}"
    replicate_acount    = "${var.replicate_acount}"
    replicate_password  = "${var.replicate_password}"
    private_key         = "${var.ssh_private_key}"
  }
}

locals {
  mysql_keyfile_dest = "~/mysql_keyfile"
  setup_script_dest  = "~/setup_replicate_slave.sh"
}

# MYSQL Slaves
resource "oci_core_instance" "TFMysqlSlave" {
  count               = "${var.number_of_slaves}"
  availability_domain = "${var.availability_domains[count.index%length(var.availability_domains)]}"

  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}${var.slave_display_name}-${count.index+1}"
  shape          = "${var.shape}"

  create_vnic_details {
    subnet_id        = "${var.subnet_ids[count.index%length(var.subnet_ids)]}"
    display_name     = "${var.label_prefix}${var.slave_display_name}-${count.index+1}"
    assign_public_ip = true
    hostname_label   = "${var.slave_display_name}-${count.index+1}"
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
      user        = "opc"
      private_key = "${file(var.ssh_private_key)}"
    }

    content = "${file(var.ssh_private_key)}"

    #destination = "/tmp/key.pem"
    destination = "${local.mysql_keyfile_dest}"
  }

  #Prepare files on slave node
  provisioner "file" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${data.template_file.install_slave.rendered}"
    destination = "${local.setup_script_dest}"
  }

  # Install slave
  provisioner "remote-exec" {
    connection = {
      host        = "${self.public_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    inline = [
      "chmod +x ${local.setup_script_dest}",
      "sudo ${local.setup_script_dest} ${count.index+1+3000}",
    ]
  }
}
