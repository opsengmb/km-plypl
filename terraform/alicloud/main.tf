// alibaba cloud provider with region
provider "alicloud" {
    region = var.region
    // latest alicloud provider version
    version = "1.133.0"
}

// terraform provider with latest required_version
terraform {
    required_version = ">=1.0"
}