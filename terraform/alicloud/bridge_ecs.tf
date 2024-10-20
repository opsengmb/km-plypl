provider "alicloud" {
    alias  = "bridge"
    region = var.bridge_region
}

resource "alicloud_security_group" "bridge-sg" {
  provider          = alicloud.bridge
  resource_group_id = alicloud_resource_manager_resource_group.rg.id
  name        = "${var.env_name}-${var.project}-bridge-sg"
  description = "${var.env_name}-${var.project} security group"
  vpc_id = module.bridge_vpc.vpc_id
}

resource "alicloud_security_group_rule" "bridge-https" {
  provider          = alicloud.bridge
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.bridge-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-http-egress" {
  provider          = alicloud.bridge
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.bridge-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-https-egress" {
  provider          = alicloud.bridge
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.bridge-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-udp-dns-egress" {
  provider          = alicloud.bridge
  type              = "egress"
  ip_protocol       = "udp"
  port_range        = "53/53"
  security_group_id = alicloud_security_group.bridge-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "bridge-tcp-dns-egress" {
  provider          = alicloud.bridge
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "53/53"
  security_group_id = alicloud_security_group.bridge-sg.id
  cidr_ip           = "0.0.0.0/0"
}
*/

resource "alicloud_instance" "bridge_ecs_instance_1" {
    provider             = alicloud.bridge
    resource_group_id    = alicloud_resource_manager_resource_group.rg.id 
    instance_name        = "${var.env_name}-${var.project}-bridge"
    image_id             = var.bridge_image_id
    instance_type        = "ecs.g7.large"
    internet_max_bandwidth_out = 100
    security_groups      = [alicloud_security_group.bridge-sg.id]
    vswitch_id           = module.bridge_vpc.vswitch_ids[0]
    password             = "dynamic_random_password"
    system_disk_category = "cloud_essd"
    system_disk_size     = 100
    tags = {
        Name = "${var.env_name}-${var.project}-bridge"
    }
}
/*
// make sure bridge_ecs_instance_1 is public
resource "alicloud_eip_association" "bridge_eip_assoc" {
    provider    = alicloud.bridge
    instance_id = alicloud_instance.bridge_ecs_instance_1.id
    allocation_id = alicloud_eip_address.bridge_eip.id
}

// define a public ip for bridge_ecs_instance_1
resource "alicloud_eip_address" "bridge_eip" {
    resource_group_id = alicloud_resource_manager_resource_group.rg.id
    provider = alicloud.bridge
    bandwidth = "100"
    internet_charge_type = "PayByTraffic"
}
*/