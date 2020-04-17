## v0.6.0 (Apr 17, 2020)

ENHANCEMENTS:

* Add S3 bucket logging configuration for FlowLogs S3 bucket.


## v0.5.0 (Apr 15, 2020)

FEATURES:

* Add new FlowLogs Using S3 as destination (#26)

## v0.4.0 (Jan 28, 2020)

ENHANCEMENTS:

* Added `additional_vpc_tags`, `additional_public_subnet_tags`, `additional_app_subnet_tags`, `additional_data_subnet_tags` (#22)

NOTES:

* Add pre-commit terraform hooks for `terraform fmt` and `terraform-docs` (#24)
* Update README to follow [terraform-aws-module-template](https://github.com/traveloka/terraform-aws-modules-template) (#24)


## v0.3.0 (Aug 7, 2019)

ENHANCEMENTS:

* **New Variable:** `additional_tags`. You can add your own tags if necessary.

## v0.2.3 (Jun 26, 2019)

BUG FIXES:

* change `ManagedBy` tag value from `Terraform` to `terraform`

## v0.2.2 (May 29, 2019)

ENHANCEMENT:

* Terraform provider version relaxed for preparation to 0.12 compatibility. Note: means that it is not working on Terraform 0.12 yet

## v0.2.1 (Sep 14, 2018)

BUG FIXES:

* add `ignore_changes` lifecycle to `aws_default_network_acl` resource because `subnet_ids` keep showing changes on `terraform plan` even though nothing is changed on previous `terraform apply`

## v0.2.0 (Apr 9, 2018)

FEATURES:

* **New Resource:** DB Subnet Group
* **New Resource:** Elasticache Subnet Group
* **New Resource:** Redshift Subnet Group

## v0.1.0 (Apr 3, 2018)

NOTES:

* Initial Release
