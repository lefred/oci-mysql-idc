output "master_instance_id" {
  value = "${module.mysql-master.id}"
}

output "master_public_ip" {
  value = "${module.mysql-master.public_ip}"
}

output "master_private_ip" {
  value = "${module.mysql-master.private_ip}"
}

output "slave_instance_ids" {
  value = "${module.mysql-slave.ids}"
}

output "slave_public_ip" {
  value = "${module.mysql-slave.public_ips}"
}

output "slave_private_ips" {
  value = "${module.mysql-slave.private_ips}"
}
