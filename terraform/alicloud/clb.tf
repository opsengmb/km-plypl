
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