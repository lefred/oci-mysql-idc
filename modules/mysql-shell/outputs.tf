output "id" {
  value = oci_core_instance.TFMysqlShell.id
}

output "private_ip" {
  value = oci_core_instance.TFMysqlShell.private_ip
}

output "public_ip" {
  value = oci_core_instance.TFMysqlShell.public_ip
}

output "shell_host_name" {
  value = oci_core_instance.TFMysqlShell.display_name
}
