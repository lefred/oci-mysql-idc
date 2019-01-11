############################################
# Datasource
############################################
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}

# Gets a list of vNIC attachments on the bastion instance
data "oci_core_vnic_attachments" "bastion" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  instance_id         = "${oci_core_instance.bastion.id}"
}
