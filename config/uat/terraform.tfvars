region  = "ap-southeast-1"
project = "playpal"
env_name = "uat"

// network details
vpc_cidr = "10.52.0.0/16"
pub_a = "10.52.0.0/24"
priv_a = "10.52.1.0/24"
priv_b = "10.52.2.0/24"
priv_c = "10.52.3.0/24"
az_a = "ap-southeast-1a"
az_b = "ap-southeast-1b"

// domains
gl_fe_domain = "betmnl.vip"
gl_be_domain = "gl-be.betmnl.vip"
bo_fe_domain = "bo-fe.betmnl.vip"
bo_be_domain = "bo-be.betmnl.vip"
jobproc_domain = "jobproc.betmnl.vip"
cert_id = "XXXXXXXX"

// image id
image_id = "ubuntu_24_04_x64_20G_alibase_20240923.vhd"
