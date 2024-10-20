variable "env_name" {
    description = "Environment Name"
}

variable "project" {
    description = "PROJECT NAME"
}

variable "region" {
    description = "REGION"
}

variable "vpc_cidr" {
    description = "VPC CIDR"
}

variable "priv_a" {
    description = "PRIVATE SWITCH"
}

variable "priv_b" {
    description = "PRIVATE SWITCH"
}

variable "priv_c" {
    description = "PRIVATE SWITCH"
}

variable "pub_a" {
    description = "PUBLIC SWITCH"
}

variable "az_a" {
    description = "AVAILABILITY ZONE"
}

variable "az_b" {
    description = "AVAILABILITY ZONE"
}

variable "image_id" {
    description = "ECS IMAGE ID"
}

variable "db_instance_type" {
    description = "DATABASE INSTANCE TYPE"
}
variable "db_instance_storage" {
    description = "DATABASE INSTANCE STORAGE"
}
