output "ids" {
  value = ["${oci_core_instance.TFMysqlSlave.*.id}"]
}

output "private_ips" {
  value = ["${oci_core_instance.TFMysqlSlave.*.private_ip}"]
}

output "slave_host_names" {
  value = ["${oci_core_instance.TFMysqlSlave.*.display_name}"]
}
