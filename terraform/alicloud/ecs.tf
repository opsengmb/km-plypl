resource "alicloud_instance" "fe_ecs_instance_1" {
  instance_name        = "${var.env_name}-${var.project}-gl-fe"
  image_id             = "m-t4n4i6s9ay3vg77czz7y"
  instance_type        = "ecs.g7.large"
  security_groups      = [alicloud_security_group.fe-sg.id]
  vswitch_id           = module.vpc.vswitch_ids[2]
  password             = "dynamic_random_password"
  system_disk_category = "cloud_essd"
  system_disk_size     = 100
  tags = {
    Name = "${var.env_name}-${var.project}-gl-fe"
  }

}

resource "alicloud_instance" "fe_ecs_instance_2" {
  instance_name        = "${var.env_name}-${var.project}-gl-be"
  image_id             = "m-t4n8kt6i8yzthf9qca6c"
  instance_type        = "ecs.g7.large"
  security_groups      = [alicloud_security_group.fe-sg.id]
  vswitch_id           = module.vpc.vswitch_ids[2]
  password             = "dynamic_random_password"
  system_disk_category = "cloud_essd"
  system_disk_size     = 100
  tags = {
    Name = "${var.env_name}-${var.project}-gl-be"
  }

}