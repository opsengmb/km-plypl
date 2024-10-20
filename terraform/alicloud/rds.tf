data "alicloud_db_zones" "default" {}


resource "alicloud_security_group" "rds-sg" {
  name        = "${var.env_name}-${var.project}-rds-sg"
  description = "${var.env_name}-${var.project} security group"
  vpc_id = module.vpc.vpc_id
}

resource "alicloud_security_group_rule" "rds-rule" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "3306/3306"
  security_group_id = alicloud_security_group.rds-sg.id
  cidr_ip           = var.vpc_cidr
}

resource "alicloud_db_instance" "default" {
  engine                   = "MariaDB"
  engine_version           = var.db_engine_version
  instance_type            = var.db_instance_type
  instance_storage         = var.db_instance_storage
  instance_name            = "${var.env_name}-${var.project}-master-rds"
  vswitch_id               = module.vpc.vswitch_ids[0]
  monitoring_period        = "60"
  db_instance_storage_type = "cloud_essd"
  category                 = var.db_category
  security_group_ids       = [alicloud_security_group.rds-sg.id]
  db_time_zone             = "UTC"
  babelfish_config {
    babelfish_enabled = false
  }
}