############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "MysqlVCN" {
  # cidr_block     = "${lookup(var.network_cidrs, "VCN-CIDR")}"
  cidr_block     = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MysqlVCN"

  # dns_label      = "ocimysql"
  dns_label = "mysql"
}

############################################
# Create Internet Gateways
############################################
resource "oci_core_internet_gateway" "MysqlIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}MysqlIG"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"
}

############################################
# Create Route Table
############################################
resource "oci_core_route_table" "MysqlRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"
  display_name   = "${var.label_prefix}MysqlRouteTable"

  route_rules {
    cidr_block = "0.0.0.0/0"

    # Internet Gateway route target for instances on public subnets
    network_entity_id = "${oci_core_internet_gateway.MysqlIG.id}"
  }
}

############################################
# Create Security List
############################################
#first protocol    = "all"
#source   = "0.0.0.0/0"
resource "oci_core_security_list" "MysqlPrivate" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}MysqlSecurityList"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"

  egress_security_rules = [{
    destination = "0.0.0.0/0"
    protocol    = "6"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "${var.vcn_cidr}"
  },
    {
      tcp_options {
        "max" = "3306"
        "min" = "3306"
      }

      protocol = "6"
      source   = "${var.vcn_cidr}"
    },
  ]
}

resource "oci_core_security_list" "bastion" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "BastionSecurityList"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"

  egress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol    = "6"
    destination = "${var.vcn_cidr}"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }]
}

############################################
# Create Subnets
############################################
locals {
  dmz_tier_prefix       = "${cidrsubnet("${var.vcn_cidr}", 4, 0)}"
  bastion_subnet_prefix = "${cidrsubnet("${local.dmz_tier_prefix}", 4, 0)}"
}

############################################
# Create Master Subnet
############################################
resource "oci_core_subnet" "MysqlMasterSubnetAD" {
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  cidr_block          = "${lookup(var.network_cidrs, "masterSubnetAD")}"
  display_name        = "${var.label_prefix}MysqlMasterSubnetAD"
  dns_label           = "masterad"
  security_list_ids   = ["${oci_core_security_list.MysqlPrivate.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MysqlVCN.id}"
  route_table_id      = "${oci_core_route_table.MysqlRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MysqlVCN.default_dhcp_options_id}"
}

############################################
# Create Slave Subnet
############################################
resource "oci_core_subnet" "MysqlSlaveSubnetAD" {
  count               = "${length(data.template_file.ad_names.*.rendered)}"
  availability_domain = "${data.template_file.ad_names.*.rendered[count.index]}"
  cidr_block          = "${lookup(var.network_cidrs, "slaveSubnetAD${count.index+1}")}"
  display_name        = "${var.label_prefix}MysqlSlaveSubnetAD${count.index+1}"
  dns_label           = "slavead${count.index+1}"

  # security_list_ids   = ["${oci_core_virtual_network.MysqlVCN.default_security_list_id}"]
  security_list_ids = ["${oci_core_security_list.MysqlPrivate.id}"]
  compartment_id    = "${var.compartment_ocid}"
  vcn_id            = "${oci_core_virtual_network.MysqlVCN.id}"
  route_table_id    = "${oci_core_route_table.MysqlRT.id}"
  dhcp_options_id   = "${oci_core_virtual_network.MysqlVCN.default_dhcp_options_id}"
}

resource "oci_core_subnet" "bastion" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "BastionAD${var.bastion_ad_index+1}"
  cidr_block          = "${cidrsubnet(local.bastion_subnet_prefix, 4, 0)}"
  security_list_ids   = ["${oci_core_security_list.bastion.id}"]
  vcn_id              = "${oci_core_virtual_network.MysqlVCN.id}"
  route_table_id      = "${oci_core_route_table.MysqlRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MysqlVCN.default_dhcp_options_id}"
}
