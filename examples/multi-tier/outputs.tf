output "aws_account_id" {
  description = "The AWS Account ID number of the account that owns or contains the calling entity."
  value       = "${module.staging.aws_account_id}"
}

output "aws_caller_arn" {
  description = "The AWS ARN associated with the calling entity."
  value       = "${module.staging.aws_caller_arn}"
}

output "aws_caller_user_id" {
  description = "The unique identifier of the calling entity."
  value       = "${module.staging.aws_caller_user_id}"
}

output "region_name" {
  description = "The name of the selected region."
  value       = "${module.staging.region_name}"
}

output "region_ec2_endpoint" {
  description = "The EC2 endpoint for the selected region."
  value       = "${module.staging.region_ec2_endpoint}"
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = "${module.staging.vpc_id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = "${module.staging.vpc_cidr_block}"
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC."
  value       = "${module.staging.vpc_instance_tenancy}"
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support."
  value       = "${module.staging.vpc_enable_dns_support}"
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support."
  value       = "${module.staging.vpc_enable_dns_hostnames}"
}

output "vpc_enable_classiclink" {
  description = "Whether or not the VPC has Classiclink enabled."
  value       = "${module.staging.vpc_enable_classiclink}"
}

output "vpc_multi_tier" {
  description = "Whether or not the VPC has Multi Tier subnets."
  value       = "${module.staging.vpc_multi_tier}"
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC."
  value       = "${module.staging.vpc_main_route_table_id}"
}

output "vpc_default_network_acl_id" {
  description = "The ID of the network ACL created by default on VPC creation."
  value       = "${module.staging.vpc_default_network_acl_id}"
}

output "vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation."
  value       = "${module.staging.vpc_default_security_group_id}"
}

output "vpc_default_route_table_id" {
  description = "The ID of the route table created by default on VPC creation."
  value       = "${module.staging.vpc_default_route_table_id}"
}

output "subnet_public_ids" {
  description = "List of IDs of public subnets."
  value       = "${module.staging.subnet_public_ids}"
}

output "subnet_public_cidr_blocks" {
  description = "List of cidr_blocks of public subnets."
  value       = "${module.staging.subnet_public_cidr_blocks}"
}

output "subnet_app_ids" {
  description = "List of IDs of app subnets."
  value       = "${module.staging.subnet_app_ids}"
}

output "subnet_app_cidr_blocks" {
  description = "List of cidr_blocks of app subnets."
  value       = "${module.staging.subnet_app_cidr_blocks}"
}

output "subnet_data_ids" {
  description = "List of IDs of data subnets."
  value       = "${module.staging.subnet_data_ids}"
}

output "subnet_data_cidr_blocks" {
  description = "List of cidr_blocks of data subnets."
  value       = "${module.staging.subnet_data_cidr_blocks}"
}

output "db_subnet_group_name" {
  description = "The db subnet group name."
  value       = "${module.staging.db_subnet_group_name}"
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group."
  value       = "${module.staging.db_subnet_group_arn}"
}

output "elasticache_subnet_group_name" {
  description = "The elasticache subnet group name."
  value       = "${module.staging.elasticache_subnet_group_name}"
}

output "redshift_subnet_group_id" {
  description = "The Redshift Subnet group ID."
  value       = "${module.staging.redshift_subnet_group_id}"
}

output "igw_id" {
  description = "The ID of the Internet Gateway."
  value       = "${module.staging.igw_id}"
}

output "eip_nat_ids" {
  description = "List of Elastic IP allocation IDs for NAT Gateway."
  value       = "${module.staging.eip_nat_ids}"
}

output "eip_nat_public_ips" {
  description = "List of Elastic IP  public IPs for NAT Gateway."
  value       = "${module.staging.eip_nat_public_ips}"
}

output "nat_ids" {
  description = "List of NAT Gateway IDs"
  value       = "${module.staging.nat_ids}"
}

output "nat_network_interface_ids" {
  description = "List of ENI IDs of the network interface created by the NAT gateway."
  value       = "${module.staging.nat_network_interface_ids}"
}

output "nat_private_ips" {
  description = "List of private IP addresses of the NAT Gateway."
  value       = "${module.staging.nat_private_ips}"
}

output "rtb_public_id" {
  description = "ID of public route table"
  value       = "${module.staging.rtb_public_id}"
}

output "rtb_app_ids" {
  description = "List of IDs of app route tables"
  value       = "${module.staging.rtb_app_ids}"
}

output "rtb_data_ids" {
  description = "List of IDs of data route tables"
  value       = "${module.staging.rtb_data_ids}"
}

output "vpce_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = "${module.staging.vpce_s3_id}"
}

output "vpce_s3_prefix_list_id" {
  description = "The prefix list for the S3 VPC endpoint."
  value       = "${module.staging.vpce_s3_prefix_list_id}"
}

output "vpce_s3_cidr_blocks" {
  description = "The list of CIDR blocks for S3 service."
  value       = "${module.staging.vpce_s3_cidr_blocks}"
}

output "vpce_dynamodb_id" {
  description = "The ID of VPC endpoint for DynamoDB"
  value       = "${module.staging.vpce_dynamodb_id}"
}

output "vpce_dynamodb_prefix_list_id" {
  description = "The prefix list for the DynamoDB VPC endpoint."
  value       = "${module.staging.vpce_dynamodb_prefix_list_id}"
}

output "vpce_dynamodb_cidr_blocks" {
  description = "The list of CIDR blocks for DynamoDB service."
  value       = "${module.staging.vpce_dynamodb_cidr_blocks}"
}

output "flow_logs_log_group_arn" {
  description = "The Amazon Resource Name (ARN) specifying the log group for VPC Flow Logs."
  value       = "${module.staging.flow_logs_log_group_arn}"
}

output "flow_logs_iam_role_name" {
  description = "The name of the role for VPC Flow Logs."
  value       = "${module.staging.flow_logs_iam_role_name}"
}

output "flow_logs_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role for VPC Flow Logs."
  value       = "${module.staging.flow_logs_iam_role_arn}"
}

output "flow_logs_iam_role_description" {
  description = "The description of the role for VPC Flow Logs."
  value       = "${module.staging.flow_logs_iam_role_description}"
}

output "flow_logs_iam_role_create_date" {
  description = "The creation date of the IAM role for VPC Flow Logs."
  value       = "${module.staging.flow_logs_iam_role_create_date}"
}

output "flow_logs_iam_role_unique_id" {
  description = "The stable and unique string identifying the role for VPC Flow Logs."
  value       = "${module.staging.flow_logs_iam_role_unique_id}"
}
