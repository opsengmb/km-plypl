
resource "alicloud_slb_load_balancer" "clb" {
  load_balancer_name = "${var.env_name}-${var.project}-slb"
  resource_group_id  = alicloud_resource_manager_resource_group.rg.id 
  address_type       = "internet"
  load_balancer_spec = "slb.s2.small"
  vswitch_id         = module.vpc.vswitch_ids[1]
  tags = {
    info = "Created by Terraform"
  }
  instance_charge_type = "PayBySpec"
}

resource "alicloud_slb_acl" "acl" {
  name       = "${var.env_name}-${var.project}-slb-acl"
  ip_version = "ipv4"
}

resource "alicloud_slb_listener" "listener" {
  load_balancer_id          = alicloud_slb_load_balancer.clb.id
  backend_port              = 80
  frontend_port             = 443
  protocol                  = "https"
  bandwidth                 = -1
  sticky_session            = "off"
  health_check              = "on"
  health_check_connect_port = 80
  healthy_threshold         = 8
  unhealthy_threshold       = 8
  health_check_timeout      = 8
  health_check_interval     = 5
  health_check_http_code    = "http_2xx,http_3xx"
  server_certificate_id = "5974218251610200_1953e511b7e_954427752_931751590"
  x_forwarded_for {
    retrive_slb_ip = true
    retrive_slb_id = true
    retrive_slb_proto = true
  }
  acl_status      = "on"
  acl_type        = "black"
  acl_ids         = [alicloud_slb_acl.acl.id]
  request_timeout = 80
  idle_timeout    = 30
}

resource "alicloud_slb_backend_server" "backend_server" {
  load_balancer_id = alicloud_slb_load_balancer.clb.id

  backend_servers {
    server_id = alicloud_instance.instance.id
    weight    = 100
  }
}


// TEMP SG
resource "alicloud_security_group" "temp-sg" {
  resource_group_id = alicloud_resource_manager_resource_group.rg.id
  name        = "${var.env_name}-${var.project}-temp-sg"
  description = "${var.env_name}-${var.project} security group"
  vpc_id = module.vpc.vpc_id
}

resource "alicloud_security_group_rule" "temp-https" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.temp-sg.id
  cidr_ip           = var.vpc_cidr
}

resource "alicloud_security_group_rule" "temp-http-egress" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.temp-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "temp-db-egress" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "3306/3306"
  security_group_id = alicloud_security_group.temp-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "temp-https-egress" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.temp-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "temp-udp-dns-egress" {
  type              = "egress"
  ip_protocol       = "udp"
  port_range        = "53/53"
  security_group_id = alicloud_security_group.temp-sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "temp-tcp-dns-egress" {
  type              = "egress"
  ip_protocol       = "tcp"
  port_range        = "53/53"
  security_group_id = alicloud_security_group.temp-sg.id
  cidr_ip           = "0.0.0.0/0"
}

// THIS IS TEMP
resource "alicloud_instance" "instance" {
  resource_group_id    = alicloud_resource_manager_resource_group.rg.id 
  instance_name        = "${var.env_name}-${var.project}-temp"
  image_id             = var.gl_be_image_id
  instance_type        = "ecs.g7.large"
  security_groups      = [alicloud_security_group.temp-sg.id]
  vswitch_id           = module.vpc.vswitch_ids[1]
  password             = "dynamic_random_password"
  system_disk_category = "cloud_essd"
  system_disk_size     = 100
  tags = {
    Name = "${var.env_name}-${var.project}-temp"
  }

}
