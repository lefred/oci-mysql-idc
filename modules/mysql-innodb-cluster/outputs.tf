
output "private_ip" {
  value = oci_core_instance.TFMysqlInnoDBClusterNode.*.private_ip
}
