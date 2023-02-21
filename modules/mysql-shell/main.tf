## DATASOURCE
# Init Script Files
data "template_file" "install_shell" {
  template = file("${path.module}/scripts/install_shell.sh")

  vars = {
    mysql_version         = var.mysql_version
    user                  = var.vm_user
  }
}

locals {
  setup_script_dest = "/home/opc/install_shell.sh"
}

resource "oci_core_instance" "TFMysqlShell" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}"
  shape            = var.node_shape
  dynamic "shape_config" {
      for_each = local.is_flexible_node_shape ? [1] : []
      content {
        memory_in_gbs = var.node_flex_shape_memory
        ocpus = var.node_flex_shape_ocpus
      }
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.display_name}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = var.display_name
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    content     = data.template_file.install_shell.rendered
    destination = local.setup_script_dest

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content      = var.bastion_private_key
    destination = "/home/${var.vm_user}/.ssh/id_rsa"

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
   
    inline = [
       "chmod +x ${local.setup_script_dest}",
       "sudo ${local.setup_script_dest}",
       "sudo chmod go-rwx /home/${var.vm_user}/.ssh/id_rsa"
    ]

   }

  timeouts {
    create = "10m"

  }
}
