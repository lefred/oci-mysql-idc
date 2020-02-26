provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
}
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}

resource "oci_core_virtual_network" "mysqlvcn" {
  cidr_block = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name = var.vcn
  dns_label = "mysqlvcn"
}


resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name = "internet_gateway"
  vcn_id = oci_core_virtual_network.mysqlvcn.id
}


resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mysqlvcn.id
  display_name   = "nat_gateway"
}


resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  display_name = "RouteTableForMySQLPublic"
  route_rules {
    cidr_block = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}


resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mysqlvcn.id
  display_name   = "RouteTableForMySQLPrivate"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_ocid
  display_name = "Allow Public SSH Connections to Bastion"
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "public_router_security_list" {
  compartment_id = var.compartment_ocid
  display_name = "Allow Public Connections to Router --warning--"
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 6447
      min = 6446
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 64460
      min = 64460
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 64470
      min = 64470
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}


resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_ocid
  display_name   = "Private"
  vcn_id         = oci_core_virtual_network.mysqlvcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules  {
    protocol = "1"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 3306
      min = 3306
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 33061
      min = 33060
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
}


resource "oci_core_subnet" "public" {
  cidr_block = cidrsubnet(var.vcn_cidr, 8, 0)
  display_name = "mysql_public_subnet"
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  route_table_id = oci_core_route_table.public_route_table.id
  security_list_ids = ["${oci_core_security_list.public_security_list.id}"]
  dhcp_options_id = oci_core_virtual_network.mysqlvcn.default_dhcp_options_id
  dns_label = "mysqlpub"
}

resource "oci_core_subnet" "private" {
  cidr_block                 = cidrsubnet(var.vcn_cidr, 8, 1)
  display_name               = "mysql_private_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.mysqlvcn.id
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = ["${oci_core_security_list.private_security_list.id}"]
  dhcp_options_id            = oci_core_virtual_network.mysqlvcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "mysqlpriv"
}

module "mysql-shell" {
  source              = "./modules/mysql-shell"
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  compartment_ocid    = "${var.compartment_ocid}"
  display_name        = "MySQLShellBastion"
  image_id            = "${var.node_image_id}"
  shape               = "${var.node_shape}"
  label_prefix        = "${var.label_prefix}"
  subnet_id           = "${oci_core_subnet.public.id}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
  bastion_private_key = "${var.bastion_private_key}"
}

module "mysql-innodb-cluster" {
  number_of_nodes       = "${var.number_of_nodes}"
  source                = "./modules/mysql-innodb-cluster"
  availability_domains  = "${data.template_file.ad_names.*.rendered}"
  use_ad                = false
  compartment_ocid      = "${var.compartment_ocid}"
  node_display_name     = "${var.node_display_name}"
  image_id              = "${var.node_image_id}"
  shape                 = "${var.node_shape}"
  label_prefix          = "${var.label_prefix}"
  subnet_id             = "${oci_core_subnet.private.id}"
  ssh_authorized_keys   = "${var.ssh_authorized_keys}"
  ssh_private_key       = "${var.ssh_private_key}"
  cluster_name          = "${var.cluster_name}"
  clusteradmin_password = "${var.clusteradmin_password}"
  bastion_public_key    = "${var.bastion_public_key}"
  bastion_private_key   = "${var.bastion_private_key}"
  bastion_ip            = var.bastion_host == null ? "${module.mysql-shell.public_ip}" : "${var.bastion_host}"
}

module "mysql-router" {
  source                = "./modules/mysql-router"
  ssh_private_key       = "${var.ssh_private_key}"
  mysql_shell_ip        = "${module.mysql-shell.public_ip}"
  clusteradmin_password = "${var.clusteradmin_password}"
  primary_ip            = "${module.mysql-innodb-cluster.private_ip}"

}
