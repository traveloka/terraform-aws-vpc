# This module was created using terraform 0.11.4 at 2018/03/21.
terraform {
  required_version = ">= 0.11.4, < 0.12.0"
}

provider "random" {
  version = ">= 1.1, < 3.0.0"
}

# Contains local values that are used to increase DRYness of the code.
locals {
  max_byte_length = "8" # max bytes of random id to use as unique suffix. 16 hex chars, each byte takes 2 hex chars

  ## Cloudwatch Log Group for VPC Flow Logs
  log_group_name_max_length      = "512"
  log_group_name_format          = "/aws/vpc-flow-logs/%s-"
  log_group_name_prefix          = "${format(local.log_group_name_format, var.vpc_name)}"
  log_group_name_max_byte_length = "${(local.log_group_name_max_length - length(local.log_group_name_prefix)) / "2"}"
  log_group_name_byte_length     = "${min(local.max_byte_length, local.log_group_name_max_byte_length)}"

  ## IAM Role for VPC Flow Logs
  role_name_max_length      = "64"
  role_name_format          = "ServiceRoleForVPCFlowLogs_%s-"
  role_name_prefix          = "${format(local.role_name_format, var.vpc_name)}"
  role_name_max_byte_length = "${(local.role_name_max_length - length(local.role_name_prefix)) / "2"}"
  role_name_byte_length     = "${min(local.max_byte_length, local.role_name_max_byte_length)}"

  common_tags = "${merge(
    var.additional_tags,
    map("ProductDomain", var.product_domain), 
    map("Environment", var.environment), 
    map("ManagedBy", "terraform"))}"
}

# Get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized.
data "aws_caller_identity" "current" {}

# Provides details about a specific AWS region.
data "aws_region" "current" {}

# Provides a VPC resource.
resource "aws_vpc" "this" {
  cidr_block = "${var.vpc_cidr_block}"

  enable_dns_support   = "${var.vpc_enable_dns_support}"
  enable_dns_hostnames = "${var.vpc_enable_dns_hostnames}"

  tags = "${merge(
    local.common_tags,
    var.additional_vpc_tags,
    map("Name", var.vpc_name),
    map("MultiTier", var.vpc_multi_tier ? "true" : "false"), 
    map("Description", format("%s VPC for %s product domain", var.environment, var.product_domain)))}"
}

# Provides VPC public subnet resources (DMZ).
# One for each AZ.
resource "aws_subnet" "public" {
  count = "${length(var.subnet_availability_zones)}"

  availability_zone       = "${element(var.subnet_availability_zones, count.index)}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, "4", count.index)}"
  map_public_ip_on_launch = "true"
  vpc_id                  = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    var.additional_public_subnet_tags,
    map("Name", format("%s-public-%s", var.vpc_name, substr(element(var.subnet_availability_zones, count.index), -1, 1))),
    map("Tier", "public"), 
    map("Description", format("Public subnet for %s AZ on %s VPC", element(var.subnet_availability_zones, count.index), var.vpc_name)))}"
}

# Provides VPC app subnet resources (Private).
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_subnet" "app" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  availability_zone = "${element(var.subnet_availability_zones, count.index)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, "3", count.index + "4")}"
  vpc_id            = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    var.additional_app_subnet_tags,
    map("Name", format("%s-app-%s", var.vpc_name, substr(element(var.subnet_availability_zones, count.index), -1, 1))),
    map("Tier", "app"), 
    map("Description", format("Application subnet for %s AZ on %s VPC", element(var.subnet_availability_zones, count.index), var.vpc_name)))}"
}

# Provides VPC data subnet resources (Private).
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_subnet" "data" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  availability_zone = "${element(var.subnet_availability_zones, count.index)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, "4", count.index + "4")}"
  vpc_id            = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    var.additional_data_subnet_tags,
    map("Name", format("%s-data-%s", var.vpc_name, substr(element(var.subnet_availability_zones, count.index), -1, 1))),
    map("Tier", "data"), 
    map("Description", format("Data subnet for %s AZ on %s VPC", element(var.subnet_availability_zones, count.index), var.vpc_name)))}"
}

# Provides an RDS DB subnet group resource.
# Only created when the VPC is multi-tier.
resource "aws_db_subnet_group" "this" {
  count = "${var.vpc_multi_tier ? "1" : "0"}"

  name        = "${var.vpc_name}-default-db-subnet-group"
  description = "Default DB Subnet Group on ${var.vpc_name} VPC"
  subnet_ids  = ["${aws_subnet.data.*.id}"]                      # For terraform 0.12 this line should be changed to aws_subnet.data[*].id

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-default-db-subnet-group", var.vpc_name)),
    map("Tier", "data"), 
    map("Description", format("Default DB Subnet Group on %s VPC", var.vpc_name)))}"
}

# Provides an ElastiCache Subnet Group resource.
# Only created when the VPC is multi-tier.
resource "aws_elasticache_subnet_group" "this" {
  count = "${var.vpc_multi_tier ? "1" : "0"}"

  name        = "${var.vpc_name}-default-elasticache-subnet-group"
  description = "Default Elasticache Subnet Group on ${var.vpc_name} VPC"
  subnet_ids  = ["${aws_subnet.data.*.id}"]                               # For terraform 0.12 this line should be changed to aws_subnet.data[*].id
}

# Creates a new Amazon Redshift subnet group.
# Only created when the VPC is multi-tier.
resource "aws_redshift_subnet_group" "this" {
  count = "${var.vpc_multi_tier ? "1" : "0"}"

  name        = "${var.vpc_name}-default-redshift-subnet-group"
  description = "Default Redshift Subnet Group on ${var.vpc_name} VPC"
  subnet_ids  = ["${aws_subnet.data.*.id}"]                            # For terraform 0.12 this line should be changed to aws_subnet.data[*].id

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-default-redshift-subnet-group", var.vpc_name)),
    map("Tier", "data"), 
    map("Description", format("Default Redshift Subnet Group on %s VPC", var.vpc_name)))}"
}

# Provides a VPC Internet Gateway resource.
resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-igw", var.vpc_name)),
    map("Description", format("Internet gateway for %s VPC", var.vpc_name)))}"
}

# Provides Elastic IP resources for NAT Gateways.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_eip" "nat" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  vpc = "true"

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-eipalloc-%s", var.vpc_name, substr(element(var.subnet_availability_zones, count.index), -1, 1))),
    map("Description", format("NAT Gateway's Elastic IP for %s AZ on %s VPC", element(var.subnet_availability_zones, count.index), var.vpc_name)))}"
}

# Provides VPC NAT Gateway resources.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_nat_gateway" "this" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.this"]

  lifecycle {
    ignore_changes = [
      "id",
    ]
  }

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-nat-%s", var.vpc_name, substr(element(var.subnet_availability_zones, count.index), -1, 1))),
    map("Description", format("NAT Gateway for %s AZ on %s VPC", element(var.subnet_availability_zones, count.index), var.vpc_name)))}"
}

# Provides a resource to manage a Default VPC Routing Table.
resource "aws_default_route_table" "this" {
  default_route_table_id = "${aws_vpc.this.default_route_table_id}"

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-default-rtb", var.vpc_name)),
    map("Tier", "default"),
    map("Description", format("Default route table for %s VPC", var.vpc_name)))}"
}

# Provides a VPC routing table for public subnets.
# One is enough, we only have one IGW anyway.
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-public-rtb", var.vpc_name)),
    map("Tier", "public"),
    map("Description", format("Route table for public subnet on %s VPC", var.vpc_name)))}"
}

# Provides a routing table entry (a route) in a VPC routing table for public subnets.
resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

# Provides resources that each create an association between a public subnet and a routing table.
# One for each AZ.
resource "aws_route_table_association" "public" {
  count = "${length(var.subnet_availability_zones)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"

  lifecycle {
    ignore_changes = [
      "id",
    ]
  }
}

# Provides VPC routing tables for app subnets.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_route_table" "app" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-app-rtb-%s", var.vpc_name, substr(element(var.subnet_availability_zones, count.index), -1, 1))),
    map("Tier", "app"),
    map("Description", format("Route table for app subnet in %s AZ of %s VPC", element(var.subnet_availability_zones, count.index), var.vpc_name)))}"
}

# Provides routing table entries (routes) in VPC routing tables for app subnets.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_route" "app" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  route_table_id         = "${element(aws_route_table.app.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"
}

# Provides resources that each create an association between an app subnet and a routing table.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_route_table_association" "app" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  subnet_id      = "${element(aws_subnet.app.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.app.*.id, count.index)}"

  lifecycle {
    ignore_changes = [
      "id",
    ]
  }
}

# Provides VPC routing tables for data subnets.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_route_table" "data" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-data-rtb-%s", var.vpc_name, substr(element(var.subnet_availability_zones, count.index), -1, 1))),
    map("Tier", "data"),
    map("Description", format("Route table for data subnet in %s AZ of %s VPC", element(var.subnet_availability_zones, count.index), var.vpc_name)))}"
}

# Provides routing table entries (routes) in VPC routing tables for DATA subnets.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_route" "data" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  route_table_id         = "${element(aws_route_table.data.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"
}

# Provides resources that each create an association between a data subnet and a routing table.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_route_table_association" "data" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  subnet_id      = "${element(aws_subnet.data.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.data.*.id, count.index)}"

  lifecycle {
    ignore_changes = [
      "id",
    ]
  }
}

# Provides a VPC Endpoint resource for S3.
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.this.id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

# Provides a resource to create an association between S3 VPC endpoint and public routing table.
resource "aws_vpc_endpoint_route_table_association" "s3_public" {
  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

# Provides resources that each create an association between S3 VPC endpoint and an app routing table.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_vpc_endpoint_route_table_association" "s3_app" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.app.*.id, count.index)}"

  lifecycle {
    ignore_changes = [
      "id",
    ]
  }
}

# Provides resources that each create an association between S3 VPC endpoint and a data routing table.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_vpc_endpoint_route_table_association" "s3_data" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.data.*.id, count.index)}"

  lifecycle {
    ignore_changes = [
      "id",
    ]
  }
}

# Provides a VPC Endpoint resource for DynamoDB.
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = "${aws_vpc.this.id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
}

# Provides a resource to create an association between DynamoDB VPC endpoint and public routing table.
resource "aws_vpc_endpoint_route_table_association" "dynamodb_public" {
  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

# Provides resources that each create an association between DynamoDB VPC endpoint and an app routing table.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_vpc_endpoint_route_table_association" "dynamodb_app" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.app.*.id, count.index)}"

  lifecycle {
    ignore_changes = [
      "id",
    ]
  }
}

# Provides resources that each create an association between DynamoDB VPC endpoint and a data routing table.
# One for each AZ.
# Only created when the VPC is multi-tier.
resource "aws_vpc_endpoint_route_table_association" "dynamodb_data" {
  count = "${var.vpc_multi_tier ? length(var.subnet_availability_zones) : "0"}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.data.*.id, count.index)}"

  lifecycle {
    ignore_changes = [
      "id",
    ]
  }
}

# Provides a resource to manage the default AWS DHCP Options Set in the current region.
resource "aws_default_vpc_dhcp_options" "this" {
  depends_on = ["aws_vpc.this"]

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-default-dopt", var.vpc_name)),
    map("Description", format("Default AWS DHCP options set for %s VPC", var.vpc_name)))}"
}

# Provides a resource to manage the default AWS Network ACL. 
resource "aws_default_network_acl" "this" {
  default_network_acl_id = "${aws_vpc.this.default_network_acl_id}"

  ingress {
    protocol   = "-1"
    rule_no    = "100"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    to_port    = "0"
  }

  egress {
    protocol   = "-1"
    rule_no    = "100"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    to_port    = "0"
  }

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-default-acl", var.vpc_name)),
    map("Description", format("Default network ACL for %s VPC", var.vpc_name)))}"

  lifecycle {
    ignore_changes = [
      "subnet_ids",
    ]
  }
}

# Provides a resource to manage the default AWS Security Group.
resource "aws_default_security_group" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(
    local.common_tags,
    map("Name", format("%s-default-sg", var.vpc_name)),
    map("Description", format("Default security group for %s VPC", var.vpc_name)))}"
}

# Generates an IAM policy document in JSON format for VPC Flow Logs Trust Relationship Policy.
data "aws_iam_policy_document" "flow_logs_trust_policy" {
  statement {
    sid     = "AllowFlowLogsToAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

# Provides an IAM role name with random value
resource "random_id" "role_name" {
  prefix      = "${local.role_name_prefix}"
  byte_length = "${local.role_name_byte_length}"
}

# Provides an IAM role for VPC Flow Logs.
resource "aws_iam_role" "flow_logs" {
  name        = "${random_id.role_name.hex}"
  description = "Service Role for VPC Flow Logs - ${var.vpc_name} VPC"
  path        = "/service-role/vpc-flow-logs.amazonaws.com/"

  assume_role_policy = "${data.aws_iam_policy_document.flow_logs_trust_policy.json}"
}

# Provides a log group name with random value
resource "random_id" "log_group_name" {
  prefix      = "${local.log_group_name_prefix}"
  byte_length = "${local.log_group_name_byte_length}"
}

# Provides a CloudWatch Log Group resource for VPC Flow Logs to store the logs.
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "${random_id.log_group_name.hex}"
  retention_in_days = "${var.flow_logs_log_group_retention_period}"

  tags = "${merge(
    local.common_tags,
    map("Name", random_id.log_group_name.hex),
    map("Description", format("VPC Flow Logs for %s VPC", var.vpc_name)))}"
}

# Generates an IAM policy document in JSON format for VPC Flow Logs Role Permission.
data "aws_iam_policy_document" "flow_logs_permission_policy" {
  statement {
    sid = "AllowWritingToLogStreams"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.flow_logs.arn}",
    ]
  }
}

# Provides an IAM role policy for VPC Flow Logs to be able to put the logs to CloudWatch Log Group.
resource "aws_iam_role_policy" "flow_logs" {
  name = "AllowVPCFlowLogsWritingToLogStreams"
  role = "${aws_iam_role.flow_logs.name}"

  policy = "${data.aws_iam_policy_document.flow_logs_permission_policy.json}"
}

# Provides a VPC Flow Log to capture IP traffic for a VPC.
resource "aws_flow_log" "this" {
  log_group_name = "${aws_cloudwatch_log_group.flow_logs.name}"
  iam_role_arn   = "${aws_iam_role.flow_logs.arn}"
  vpc_id         = "${aws_vpc.this.id}"
  traffic_type   = "ALL"

  depends_on = ["aws_iam_role_policy.flow_logs"]
}
