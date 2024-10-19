// alibaba backend configuration for terraform
terraform {
  backend "oss" {
    bucket = "dynamic_env-bucket"
    key   = "dynamic_env-state.tfstate"
    region = "ap-southeast-6"
  }
}