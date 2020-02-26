
output "private_ip" {
  value = "${oci_core_instance.TFMysqlInnoDBCluterNode.*.private_ip}"
}