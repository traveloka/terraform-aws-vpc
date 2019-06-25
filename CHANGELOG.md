## v0.3.0 (Unreleased)

NOTES:

* This module is now compatible with Terraform 0.12 version. That being said, one can still use this module on previous version of Terraform (0.11). The reason behind that is because the syntax is not using Terraform 0.12's style yet.

## v0.2.2 (May 29, 2019)

ENHANCEMENT:

* Terraform provider version relaxed for preparation to 0.12 compatibility

## v0.2.1 (Sep 14, 2018)

BUG FIXES:

* add `ignore_changes` lifecycle to `aws_default_network_acl` resource because `subnet_ids` keep showing changes on `terraform plan` even though nothing is changed on previous `terraform apply`

## v0.2.0 (Apr 9, 2018)

FEATURES:

* **New Resource:** Automatically create DB Subnet Group, Elasticache Subnet Group, and Redshift Subnet Group

## v0.1.0 (Apr 3, 2018)

NOTES:

* Initial Release
