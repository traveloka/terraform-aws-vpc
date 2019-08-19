variable "product_domain" {
  description = "Product domain these resources belong to."
  type        = "string"
}

variable "environment" {
  description = "Type of environment these resources belong to."
  type        = "string"
}

variable "vpc_name" {
  description = "The name of the VPC. This name will be used as the prefix for all VPC components."
  type        = "string"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = "string"
}

variable "vpc_enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  default     = "true"
}

variable "vpc_enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults true."
  default     = "true"
}

variable "vpc_multi_tier" {
  description = "Whether this VPC should have 3 tiers. True means 3-tier, false means single-tier. Defaults true. Recommended value is true."
  default     = "true"
}

variable "subnet_availability_zones" {
  description = "List of AZs to spread VPC subnets over."
  type        = "list"

  default = [
    "ap-southeast-1a",
    "ap-southeast-1b",
    "ap-southeast-1c",
  ]
}

variable "flow_logs_log_group_retention_period" {
  description = "Specifies the number of days you want to retain log events in the specified log group."
  default     = "14"
}

variable "additional_tags" {
  description = "A map of additional tags to add to all resources"
  default     = {}
}

variable "additional_vpc_tags" {
  description = "A map of additional tags to add to the vpc"
  default     = {}
}

variable "additional_public_subnet_tags" {
  description = "A map of additional tags to add to the public subnet"
  default     = {}
}

variable "additional_app_subnet_tags" {
  description = "A map of additional tags to add to the application subnet"
  default     = {}
}

variable "additional_data_subnet_tags" {
  description = "A map of additional tags to add to the data subnet"
  default     = {}
}
