
// terraform provider with latest required_version
terraform {
    required_version = ">=1.0"
    required_providers {
        alibabacloudstack = {
        source  = "registry.terraform.io/terraform-alibabacloudstack/alibabacloudstack"
        version = ">= 1.0.0"
     }
  }
}

// add alicloud provider
provider "alicloud" {
  region = var.region
}