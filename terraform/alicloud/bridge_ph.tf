// new provider with different region
provider "alicloud" {
  alias   = "bridgeph"
  region  = "ap-southeast-6"
}

data "alicloud_zones" "bridge_zones_ph" {
  provider          = alicloud.bridgeph
  available_resource_creation = "VSwitch"
}


resource "alicloud_vpc" "bridge_vpc_ph" {
  provider          = alicloud.bridgeph
  vpc_name   = "${var.env_name}-${var.project}-vpc-ph"
  cidr_block = var.bridge_vpc_ph_cidr
  resource_group_id = alicloud_resource_manager_resource_group.rg.id 
}

resource "alicloud_vswitch" "bridge_vswitch_a_ph" {
  provider          = alicloud.bridgeph
  vswitch_name = "${var.env_name}-${var.project}-vswitch-a-ph"
  vpc_id       = alicloud_vpc.bridge_vpc_ph.id
  cidr_block   = var.bridge_pub_a_ph
  zone_id      = data.alicloud_zones.bridge_zones_ph.zones.0.id
}


resource "alicloud_nat_gateway" "bridge_int_nat_gw1_ph" {
  provider          = alicloud.bridgeph
  vpc_id           = alicloud_vpc.bridge_vpc_ph.id
  nat_gateway_name = "${var.env_name}-${var.project}-ingw1-ph"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.bridge_vswitch_a_ph.id
  nat_type         = "Enhanced"
}

resource "alicloud_eip_association" "bridge_int_nat_assoc1_ph" {
  provider          = alicloud.bridgeph
  allocation_id = alicloud_eip_address.bridge_eip_addr_snat1_ph.id
  instance_type = "Nat"
  instance_id   = alicloud_nat_gateway.bridge_int_nat_gw1_ph.id
}

resource "alicloud_eip_address" "bridge_eip_addr_snat1_ph" {
  provider          = alicloud.bridgeph
  address_name  = "${var.env_name}-${var.project}-eipaddr1-ph"
  resource_group_id = alicloud_resource_manager_resource_group.rg.id 
}

resource "alicloud_snat_entry" "bridge_int_nat_snat1_ph" {
  provider          = alicloud.bridgeph
  snat_table_id     = alicloud_nat_gateway.bridge_int_nat_gw1_ph.snat_table_ids
  source_vswitch_id = alicloud_vswitch.bridge_vswitch_a_ph.id
  snat_ip           = alicloud_eip_address.bridge_eip_addr_snat1_ph.ip_address
}

// SGRP
resource "alicloud_security_group" "bridge-sg-ph" {
  provider          = alicloud.bridgeph
  resource_group_id = alicloud_resource_manager_resource_group.rg.id
  name        = "${var.env_name}-${var.project}-bridge-sg-ph"
  description = "${var.env_name}-${var.project} security group"
  vpc_id = alicloud_vpc.bridge_vpc_ph.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "alicloud_security_group_rule" "bridge-http-ph" {
  provider          = alicloud.bridgeph
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.bridge-sg-ph.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-https-ph" {
  provider          = alicloud.bridgeph
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.bridge-sg-ph.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-http-egress-ph" {
  provider          = alicloud.bridgeph
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.bridge-sg-ph.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-https-egress-ph" {
  provider          = alicloud.bridgeph
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.bridge-sg-ph.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-udp-dns-egress-ph" {
  provider          = alicloud.bridgeph
  type              = "egress"
  ip_protocol       = "udp"
  port_range        = "53/53"
  security_group_id = alicloud_security_group.bridge-sg-ph.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-tcp-dns-egress-ph" {
  provider          = alicloud.bridgeph
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "53/53"
  security_group_id = alicloud_security_group.bridge-sg-ph.id
  cidr_ip           = "0.0.0.0/0"
}


resource "alicloud_instance" "bridge_ecs_instance_1_ph" {
    provider             = alicloud.bridgeph
    resource_group_id    = alicloud_resource_manager_resource_group.rg.id 
    instance_name        = "${var.env_name}-${var.project}-bridge-ph"
    image_id             = var.bridge_image_id_ph
    instance_type        = "ecs.g7.large"
    security_groups      = [alicloud_security_group.bridge-sg-ph.id]
    vswitch_id           = alicloud_vswitch.bridge_vswitch_a_ph.id
    password             = "dynamic_random_password"
    system_disk_category = "cloud_essd"
    system_disk_size     = 100
    tags = {
        Name = "${var.env_name}-${var.project}-bridge-ph"
    }
}

// define a public ip for bridge_ecs_instance_1
resource "alicloud_eip_address" "bridge_eip_ph" {
    resource_group_id = alicloud_resource_manager_resource_group.rg.id
    provider = alicloud.bridgeph
    bandwidth = "100"
    internet_charge_type = "PayByTraffic"
}

// make sure bridge_ecs_instance_1 is public
resource "alicloud_eip_association" "bridge_eip_assoc_ph" {
    provider    = alicloud.bridgeph
    instance_id = alicloud_instance.bridge_ecs_instance_1_ph.id
    allocation_id = alicloud_eip_address.bridge_eip_ph.id
}
