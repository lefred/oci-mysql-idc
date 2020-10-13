## DATASOURCE
# Init Script Files
data "template_file" "install_mysql" {
  template = file("${path.module}/scripts/install_mysql.sh")

  vars = {
    mysql_version         = var.mysql_version
    cluster_name          = var.cluster_name
    clusteradmin_password = var.clusteradmin_password
    bastion_ip            = var.bastion_ip
  }
}

data "template_file" "install_cluster" {
  template = file("${path.module}/scripts/install_cluster.sh")

  vars = {
    mysql_version         = var.mysql_version
    cluster_name          = var.cluster_name
    clusteradmin_password = var.clusteradmin_password
    bastion_ip            = var.bastion_ip
  }
}

locals {
  setup_script_dest    = "~/install_mysql.sh"
  cluster_script_dest  = "~/install_cluster.sh"
  fault_domains_per_ad = 3
}

## MYSQL REPLICATION MASTER INSTANCE
resource "oci_core_instance" "TFMysqlInnoDBClusterNode" {
  count               = var.number_of_nodes
  availability_domain = var.use_AD == false ? var.availability_domains[0] : var.availability_domains[count.index%length(var.availability_domains)]
  fault_domain        = var.use_AD == true ? "FAULT-DOMAIN-1" : "FAULT-DOMAIN-${(count.index  % local.fault_domains_per_ad) +1}"
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.node_display_name}${count.index+1}"
  shape               = var.shape

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.node_display_name}${count.index+1}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "${var.node_display_name}${count.index+1}"
  }

  metadata = {
    ssh_authorized_keys = var.bastion_public_key
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    content     = data.template_file.install_mysql.rendered
    destination = local.setup_script_dest

    connection  {
      type        = "ssh"
      host        = self.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.bastion_private_key

      bastion_host = var.bastion_ip
      bastion_user = var.vm_user
      bastion_private_key = var.ssh_private_key
    }
  }

  provisioner "file" {
    content     = data.template_file.install_cluster.rendered
    destination = local.cluster_script_dest

    connection  {
      type        = "ssh"
      host        = self.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.bastion_private_key

      bastion_host = var.bastion_ip
      bastion_user = var.vm_user
      bastion_private_key = var.ssh_private_key
    }

  }
   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.bastion_private_key

      bastion_host = var.bastion_ip
      bastion_user = var.vm_user
      bastion_private_key = var.ssh_private_key
    }
   
    inline = [
       "chmod +x ${local.setup_script_dest}",
       "sudo ${local.setup_script_dest}"
    ]

   }

  provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.bastion_private_key

      bastion_host = var.bastion_ip
      bastion_user = var.vm_user
      bastion_private_key = var.ssh_private_key
    }
   
    inline = [
       "chmod +x ${local.cluster_script_dest}",
       "sudo ${local.cluster_script_dest}"
    ]

   }

  timeouts {
    create = "10m"
  }
}
