resource "alicloud_security_group" "be-sg" {
  name        = "${var.env_name}-${var.project}-fe-sg"
  description = "${var.env_name}-${var.project} security group"
  vpc_id = module.vpc.vpc_id
}

resource "alicloud_security_group_rule" "be-https" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.be-sg.id
  cidr_ip           = var.vpc_cidr
}

resource "alicloud_security_group_rule" "be-http-egress" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.be-sg.id
  cidr_ip           = var.vpc_cidr
}

resource "alicloud_security_group_rule" "be-https-egress" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.be-sg.id
  cidr_ip           = var.vpc_cidr
}

resource "alicloud_security_group_rule" "be-udp-dns-egress" {
  type              = "egress"
  ip_protocol       = "udp"
  port_range        = "53/53"
  security_group_id = alicloud_security_group.be-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "be-tcp-dns-egress" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "53/53"
  security_group_id = alicloud_security_group.be-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "be_ecs_instance_1" {
  resource_group_id    = alicloud_resource_manager_resource_group.rg.id 
  instance_name        = "${var.env_name}-${var.project}-gl-be"
  image_id             = "m-t4n4i6s9ay3vg77czz7y"
  instance_type        = "ecs.g7.large"
  security_groups      = [alicloud_security_group.be-sg.id]
  vswitch_id           = module.vpc.vswitch_ids[1]
  password             = "dynamic_random_password"
  system_disk_category = "cloud_essd"
  system_disk_size     = 100
  tags = {
    Name = "${var.env_name}-${var.project}-gl-be"
  }

}
