# terraform-aws-vpc

[![Terraform Version](https://img.shields.io/badge/Terraform%20Version-0.11.14-blue.svg)](https://releases.hashicorp.com/terraform/)
[![Release](https://img.shields.io/github/release/traveloka/terraform-aws-vpc.svg)](https://github.com/traveloka/terraform-aws-vpc/releases)
[![Last Commit](https://img.shields.io/github/last-commit/traveloka/terraform-aws-vpc.svg)](https://github.com/traveloka/terraform-aws-vpc/commits/master)
[![Issues](https://img.shields.io/github/issues/traveloka/terraform-aws-vpc.svg)](https://github.com/traveloka/terraform-aws-vpc/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/traveloka/terraform-aws-vpc.svg)](https://github.com/traveloka/terraform-aws-vpc/pulls)
[![License](https://img.shields.io/github/license/traveloka/terraform-aws-vpc.svg)](https://github.com/traveloka/terraform-aws-vpc/blob/master/LICENSE)
![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.png?v=103)

## Table of Content

- [Prerequisites](#Prerequisites)
- [Quick Start](#Quick-Start)
- [Dependencies](#Dependencies)
- [Contributing](#Contributing)
- [Contributor](#Contributor)
- [License](#License)
- [Acknowledgments](#Acknowledgments)

## Prerequisites

- [Terraform](https://releases.hashicorp.com/terraform/). This module currently tested on `0.11.14`

## Quick Start
Terraform module to create all mandatory VPC components.

This module supports either single-tier (only public subnet) or multi-tier (public-app-data subnets) VPC creation.
This module supports only up to 4 AZs.

### Multi-Tier VPC

```hcl
module "abc_dev" {
  source  = "traveloka/vpc/aws"
  version = "v0.2.3"
  
  product_domain = "abc"
  environment    = "dev"

  vpc_name       = "abc-dev"
  vpc_cidr_block = "172.16.0.0/16"
}
```

We use multi-tier architecture for our VPC design. This design divides the infrastructure into three layers: 
- Public tier: entrypoint for public-facing client. Using public subnet since resources in this tier will be discoverable through Internet. Examples: external load balancer, bastion, etc.
- Application Tier: this is where the business logic services life and communicate each others. This tier using private subnet, hence it's only accessible through private network.
- Database Tier: this is where databases life. Application and databases are seperated to have clear boundaries and secure access through application tier.

Benefits or having multi-tier architecture are:
- Scalable
- Gives us high availability and redundancy
- Fit with microservices architecture
- Clear boundaries between public-facing, business logic, and data storage
- Secure and reduce risk, because by default any services life at private subnet, and database only accessible through the application tier.

### Single-Tier VPC

In some cases, you will need a VPC which has only public subnets.

```hcl
module "abc_dev" {
  source  = "traveloka/vpc/aws"
  version = "v0.2.3"

  # you only need to add this line
  vpc_multi_tier = false 

  # ... omitted
}
```

In some situations (it is not always happening), you will get some errors from Terraform when you set `vpc_multi_tier = false`.
It happens because several resources were not created but stated as the outputs.
Currrently Terraform does not allow `count` inside `output` block, so now it is inevitable.
But don't worry, the errors have nothing to do with the stacks/resources/infrastructures that you created.
Just re-execute `terraform apply` and you will be fine.

### Examples

* [Multi-Tier VPC](https://github.com/traveloka/terraform-aws-vpc/tree/master/examples/multi-tier)

### Module


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | >= 1.1, < 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_tags | A map of additional tags to add to all resources | `map` | `{}` | no |
| environment | Type of environment these resources belong to. | `string` | n/a | yes |
| flow\_logs\_log\_group\_retention\_period | Specifies the number of days you want to retain log events in the specified log group. | `string` | `"14"` | no |
| product\_domain | Product domain these resources belong to. | `string` | n/a | yes |
| subnet\_availability\_zones | List of AZs to spread VPC subnets over. | `list` | <pre>[<br>  "ap-southeast-1a",<br>  "ap-souStheast-1b",<br>  "ap-southeast-1c"<br>]<br></pre> | no |
| vpc\_cidr\_block | The CIDR block for the VPC. | `string` | n/a | yes |
| vpc\_enable\_dns\_hostnames | A boolean flag to enable/disable DNS hostnames in the VPC. Defaults true. | `string` | `"true"` | no |
| vpc\_enable\_dns\_support | A boolean flag to enable/disable DNS support in the VPC. Defaults true. | `string` | `"true"` | no |
| vpc\_multi\_tier | Whether this VPC should have 3 tiers. True means 3-tier, false means single-tier. Defaults true. Recommended value is true. | `string` | `"true"` | no |
| vpc\_name | The name of the VPC. This name will be used as the prefix for all VPC components. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_account\_id | The AWS Account ID number of the account that owns or contains the calling entity. |
| aws\_caller\_arn | The AWS ARN associated with the calling entity. |
| aws\_caller\_user\_id | The unique identifier of the calling entity. |
| db\_subnet\_group\_arn | The ARN of the db subnet group. |
| db\_subnet\_group\_name | The db subnet group name. |
| eip\_nat\_ids | List of Elastic IP allocation IDs for NAT Gateway. |
| eip\_nat\_public\_ips | List of Elastic IP  public IPs for NAT Gateway. |
| elasticache\_subnet\_group\_name | The elasticache subnet group name. |
| flow\_logs\_iam\_role\_arn | The Amazon Resource Name (ARN) specifying the role for VPC Flow Logs. |
| flow\_logs\_iam\_role\_create\_date | The creation date of the IAM role for VPC Flow Logs. |
| flow\_logs\_iam\_role\_description | The description of the role for VPC Flow Logs. |
| flow\_logs\_iam\_role\_name | The name of the role for VPC Flow Logs. |
| flow\_logs\_iam\_role\_unique\_id | The stable and unique string identifying the role for VPC Flow Logs. |
| flow\_logs\_log\_group\_arn | The Amazon Resource Name (ARN) specifying the log group for VPC Flow Logs. |
| igw\_id | The ID of the Internet Gateway. |
| nat\_ids | List of NAT Gateway IDs |
| nat\_network\_interface\_ids | List of ENI IDs of the network interface created by the NAT gateway. |
| nat\_private\_ips | List of private IP addresses of the NAT Gateway. |
| redshift\_subnet\_group\_id | The Redshift Subnet group ID. |
| region\_ec2\_endpoint | The EC2 endpoint for the selected region. |
| region\_name | The name of the selected region. |
| rtb\_app\_ids | List of IDs of app route tables |
| rtb\_data\_ids | List of IDs of data route tables |
| rtb\_public\_id | ID of public route table |
| subnet\_app\_cidr\_blocks | List of cidr\_blocks of app subnets. |
| subnet\_app\_ids | List of IDs of app subnets. |
| subnet\_data\_cidr\_blocks | List of cidr\_blocks of data subnets. |
| subnet\_data\_ids | List of IDs of data subnets. |
| subnet\_public\_cidr\_blocks | List of cidr\_blocks of public subnets. |
| subnet\_public\_ids | List of IDs of public subnets. |
| vpc\_cidr\_block | The CIDR block of the VPC. |
| vpc\_default\_network\_acl\_id | The ID of the network ACL created by default on VPC creation. |
| vpc\_default\_route\_table\_id | The ID of the route table created by default on VPC creation. |
| vpc\_default\_security\_group\_id | The ID of the security group created by default on VPC creation. |
| vpc\_enable\_classiclink | Whether or not the VPC has Classiclink enabled. |
| vpc\_enable\_dns\_hostnames | Whether or not the VPC has DNS hostname support. |
| vpc\_enable\_dns\_support | Whether or not the VPC has DNS support. |
| vpc\_id | The ID of the VPC. |
| vpc\_instance\_tenancy | Tenancy of instances spin up within VPC. |
| vpc\_main\_route\_table\_id | The ID of the main route table associated with this VPC. |
| vpc\_multi\_tier | Whether or not the VPC has Multi Tier subnets. |
| vpce\_dynamodb\_cidr\_blocks | The list of CIDR blocks for DynamoDB service. |
| vpce\_dynamodb\_id | The ID of VPC endpoint for DynamoDB |
| vpce\_dynamodb\_prefix\_list\_id | The prefix list for the DynamoDB VPC endpoint. |
| vpce\_s3\_cidr\_blocks | The list of CIDR blocks for S3 service. |
| vpce\_s3\_id | The ID of VPC endpoint for S3 |
| vpce\_s3\_prefix\_list\_id | The prefix list for the S3 VPC endpoint. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

Apache 2 Licensed. See LICENSE for full details.

## Acknowledgement
