## v0.2.3 (June 30, 2019)

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
