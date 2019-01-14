# output "master_public_ip" {
#   value = "${module.mysql.master_public_ip}"
# }

output "master_private_ip" {
  value = "${module.mysql-replication-set.master_private_ip}"
}

# output "slave_public_ip" {
#   value = "${module.mysql.slave_public_ip}"
# }

output "slave_private_ips" {
  value = "${module.mysql-replication-set.slave_private_ips}"
}
