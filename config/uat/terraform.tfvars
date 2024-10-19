region  = "ap-southeast-1"
project = "imba"
env_name = "prod"

// network details
vpc_cidr = "10.1.0.0/16"
priv_d = "10.1.0.0/24"
priv_a = "10.1.2.0/24"
priv_b = "10.1.3.0/24"
priv_c = "10.1.4.0/24"
az_a = "ap-southeast-1a"
az_b = "ap-southeast-1b"

// domains
gl_fe_domain = "betmnl.vip"
gl_be_domain = "gl-be.betmnl.vip"
bo_fe_domain = "bo-fe.betmnl.vip"
bo_be_domain = "bo-be.betmnl.vip"
jobproc_domain = "jobproc.betmnl.vip"
#socket_domain  = "socket.betmnl.vip"
cert_id = "57230-ap-southeast-1"

// Back Office
#bo_fe_ami_id = "aliyun_3_x64_20G_qboot_alibase_20230727.vhd"
#bo_fe_instance_type = "ecs.t6-c4m1.large"

// db instance details
#master_instance_class = "db.t3.small"