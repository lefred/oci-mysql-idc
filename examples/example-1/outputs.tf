output "master_public_ip" {
  value = "${module.mysql.master_public_ip}"
}

output "slave_private_ips" {
  value = "${module.mysql.slave_private_ips}"
}

#output "master_login_info" {
#  value = "${module.mysql.master_login_info}"
#}

