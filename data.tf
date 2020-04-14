data "aws_iam_policy_document" "flowlogs_to_s3" {
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }

    resources = [
      "arn:aws:s3:::${module.flowlogs_to_s3_naming.name}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
    ]

    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }

    resources = [
      "arn:aws:s3:::${module.flowlogs_to_s3_naming.name}",
    ]
  }
}
