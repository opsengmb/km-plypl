module "bridge_vpc" {
  source  = "alibaba/vpc/alicloud"

  create            = true
  vpc_name          = "${var.env_name}-${var.project}-vpc"
  vpc_cidr          = var.bridge_vpc_cidr
  resource_group_id = alicloud_resource_manager_resource_group.rg.id

  availability_zones = [var.bridge_az_a]
  vswitch_cidrs      = [var.bridge_pub_a]

  vpc_tags = {
    Environment = var.env_name
    Name        = "${var.env_name}-${var.project}-vpc"
  }

  vswitch_tags = {
    Environment  = var.env_name
  }
}

resource "alicloud_nat_gateway" "bridge_int_nat_gw1" {
  vpc_id           = module.bridge_vpc.vpc_id
  nat_gateway_name = "${var.env_name}-${var.project}-ingw1"
  payment_type     = "PayAsYouGo"
  vswitch_id       = module.bridge_vpc.vswitch_ids[0]
  nat_type         = "Enhanced"
}

resource "alicloud_eip_association" "bridge_int_nat_assoc1" {
  allocation_id = alicloud_eip_address.bridge_eip_addr_snat1.id
  instance_type = "Nat"
  instance_id   = alicloud_nat_gateway.bridge_int_nat_gw1.id
}

resource "alicloud_eip_address" "bridge_eip_addr_snat1" {
  address_name  = "${var.env_name}-${var.project}-eipaddr1"
  resource_group_id = alicloud_resource_manager_resource_group.rg.id 
}


resource "alicloud_snat_entry" "int_nat_snat1" {
  snat_table_id     = alicloud_nat_gateway.bridge_int_nat_gw1.snat_table_ids
  source_vswitch_id = module.vpc.vswitch_ids[0]
  snat_ip           = alicloud_eip_address.eip_addbridge_eip_addr_snat1r_snat1.ip_address
}
