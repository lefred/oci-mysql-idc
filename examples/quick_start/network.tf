############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "MysqlVCN" {
  cidr_block     = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MysqlVCN"
  dns_label      = "mysql"
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
# Create NAT Gateway
############################################
resource "oci_core_nat_gateway" "MysqlNG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"
  display_name   = "MysqlNG"
}

############################################
# Create Route Table
############################################
resource "oci_core_route_table" "MysqlPublicRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"
  display_name   = "${var.label_prefix}MysqlPublicRT"

  route_rules {
    cidr_block       = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    # Internet Gateway route target for instances on public subnets
    network_entity_id = "${oci_core_internet_gateway.MysqlIG.id}"
  }
}

resource "oci_core_route_table" "MysqlPrivateRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"
  display_name   = "MysqlPrivateRT"

  route_rules {
    cidr_block       = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    # Internet Gateway route target for instances on public subnets
    network_entity_id = "${oci_core_nat_gateway.MysqlNG.id}"
  }
}

############################################
# Create Security List
############################################
resource "oci_core_security_list" "MysqlPrivate" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}private"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"

  egress_security_rules = [{
    destination = "0.0.0.0/0"
    protocol    = "all"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = "${var.http_port}"
        "min" = "${var.http_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
  ]
}

resource "oci_core_security_list" "bastion" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "bastion"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"

  egress_security_rules = [{
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

resource "oci_core_security_list" "nat" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "nat"
  vcn_id         = "${oci_core_virtual_network.MysqlVCN.id}"

  egress_security_rules = [{
    protocol    = "6"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    protocol = "6"
    source   = "${var.vcn_cidr}"
  }]
}

############################################
# Create Master Subnet
############################################
resource "oci_core_subnet" "MysqlMasterSubnetAD" {
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  cidr_block          = "${cidrsubnet("${local.master_subnet_prefix}", 4, 0)}"
  display_name        = "${var.label_prefix}MysqlMasterSubnetAD"
  dns_label           = "masterad"
  security_list_ids   = ["${oci_core_security_list.MysqlPrivate.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MysqlVCN.id}"
  route_table_id      = "${oci_core_route_table.MysqlPrivateRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MysqlVCN.default_dhcp_options_id}"
}

############################################
# Create Slave Subnet
############################################
resource "oci_core_subnet" "MysqlSlaveSubnetAD" {
  count               = "${length(data.template_file.ad_names.*.rendered)}"
  availability_domain = "${data.template_file.ad_names.*.rendered[count.index]}"
  cidr_block          = "${cidrsubnet("${local.slave_subnet_prefix}", 4, count.index)}"
  display_name        = "${var.label_prefix}MysqlSlaveSubnetAD${count.index+1}"
  dns_label           = "slavead${count.index+1}"
  security_list_ids   = ["${oci_core_security_list.MysqlPrivate.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MysqlVCN.id}"
  route_table_id      = "${oci_core_route_table.MysqlPrivateRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MysqlVCN.default_dhcp_options_id}"
}

############################################
# Create Bastion Subnet
############################################
resource "oci_core_subnet" "bastion" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "BastionAD${var.bastion_ad_index+1}"
  cidr_block          = "${cidrsubnet(local.bastion_subnet_prefix, 3, 0)}"
  security_list_ids   = ["${oci_core_security_list.bastion.id}"]
  vcn_id              = "${oci_core_virtual_network.MysqlVCN.id}"
  route_table_id      = "${oci_core_route_table.MysqlPublicRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.MysqlVCN.default_dhcp_options_id}"
}
