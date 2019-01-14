output "bastion_public_ip" {
  value = ["${oci_core_instance.bastion.public_ip}"]
}

output "slave_private_ips" {
  value = "${module.mysql-replication-set.slave_private_ips}"
}

output "master_private_ip" {
  value = "${module.mysql-replication-set.master_private_ip}"
}
