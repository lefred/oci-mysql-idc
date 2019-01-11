# output "bastion_public_ip" {
#   value = ["${data.oci_core_vnic.bastion.public_ip_address}"]
# }

output "slave_private_ips" {
  value = "${module.mysql-replication-set.slave_private_ips}"
}

output "master_private_ip" {
  value = "${module.mysql-replication-set.master_private_ip}"
}
