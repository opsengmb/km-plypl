// alibaba cloud provider with region
provider "alicloud" {
    region = var.region
}

// terraform provider with latest required_version
terraform {
    required_version = ">=1.0"
}