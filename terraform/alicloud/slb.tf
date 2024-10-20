data "alicloud_alb_zones" "default" {}

resource "alicloud_alb_load_balancer" "default" {
  vpc_id                 = module.vpc.vpc_id
  resource_group_id     = alicloud_resource_manager_resource_group.rg.id 
  address_type           = "Internet"
  address_allocated_mode = "Fixed"
  load_balancer_name     = "${var.env_name}-${var.project}-lb"
  load_balancer_edition  = "StandardWithWaf"
  load_balancer_billing_config {
    pay_type = "PayAsYouGo"
  }
  tags = {
    name = "${var.env_name}-${var.project}-intra-lb"
  }
  zone_mappings {
    vswitch_id = module.vpc.vswitch_ids[1]
    zone_id    = data.alicloud_alb_zones.default.zones.0.id
  }
   zone_mappings {
    vswitch_id = module.vpc.vswitch_ids[2]
    zone_id    = data.alicloud_alb_zones.default.zones.1.id
  }
  modification_protection_config {
    status = "NonProtection"
  }
}

resource "alicloud_alb_listener" "default_80" {
  load_balancer_id     = alicloud_alb_load_balancer.default.id
  listener_protocol    = "HTTP"
  listener_port        = 80
  listener_description = "${var.env_name}-${var.project}-80-listener"
  x_forwarded_for_config {
    x_forwarded_for_proto_enabled = true
    x_forwarded_for_enabled = true
  }
  default_actions {
    type = "ForwardGroup"
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.gl_be_grp.id
      }
    }
  }
}

/*
resource "alicloud_alb_listener" "default_443" {
  load_balancer_id     = alicloud_alb_load_balancer.default.id
  listener_protocol    = "HTTPS"
  listener_port        = 443
  listener_description = "${var.env_name}-${var.project}-443-listener"
  x_forwarded_for_config {
    x_forwarded_for_proto_enabled = true
    x_forwarded_for_enabled = true
  }
  default_actions {
    type = "ForwardGroup"
    forward_group_config {
      server_group_tuples {
       server_group_id = alicloud_alb_server_group.gl_fe_grp.id
      }
    }
  }
  certificates {
    certificate_id = var.cert_id
  }
}

resource "alicloud_alb_rule" "gl_fe_rule" {
  rule_name   = "${var.env_name}-${var.project}-fe-rule"
  listener_id = alicloud_alb_listener.default_80.id
  priority    = "1"
  rule_conditions {
    type = "Host"
    host_config {
      values = ["${var.gl_fe_domain}"]
    }
  }

  rule_actions {
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.gl_fe_grp.id
      }
    }
    order = "1"
    type  = "ForwardGroup"
  }
}

resource "alicloud_alb_rule" "gl_fe_rule_https" {
  rule_name   = "${var.env_name}-${var.project}-fe-rule-https"
  listener_id = alicloud_alb_listener.default_443.id
  priority    = "1"
  rule_conditions {
    type = "Host"
    host_config {
      values = ["${var.gl_fe_domain}"]
    }
  }

  rule_actions {
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.gl_fe_grp.id
      }
    }
    order = "1"
    type  = "ForwardGroup"
  }
}
*/
resource "alicloud_alb_server_group" "gl_be_grp" {
  protocol          = "HTTP"
  vpc_id            = module.vpc.vpc_id
  server_group_name = "${var.env_name}-${var.project}-gl-be-grp"
  resource_group_id = alicloud_resource_manager_resource_group.rg.id 
  health_check_config {
    health_check_connect_port = "80"
    health_check_enabled      = true
    health_check_codes        = ["http_2xx", "http_3xx"]
    health_check_interval     = "2"
    health_check_protocol     = "TCP"
    health_check_timeout      = 5
    healthy_threshold         = 3
    unhealthy_threshold       = 3
  }
  sticky_session_config {
    sticky_session_enabled = false
    cookie                 = "tf-example"
    sticky_session_type    = "Server"
  }
  servers {
    description = "${var.env_name}-${var.project}-gl-be"
    port        = 80
    server_id   = alicloud_instance.be_ecs_instance_1.id
    server_type = "Ecs"
  }
}
