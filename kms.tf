resource "aws_kms_key" "this" {
  count                    = var.kms_key == null ? 1 : 0
  description              = "KMS key for MWAA created by idealo/terraform-aws-mwaa"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  multi_region             = false
  policy                   = data.aws_iam_policy_document.kms_log_access[0].json
  tags                     = var.tags
}

data "aws_iam_policy_document" "kms_log_access" {
  count   = var.kms_key == null ? 1 : 0
  version = "2012-10-17"
  statement {
    sid       = "Allow logs access"
    effect    = "Allow"
    principals {
      identifiers = [
        "logs.${var.region}.amazonaws.com"
      ]
      type        = "Service"
    }
    actions   = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "ArnLike"
      values   = [
        "arn:aws:logs:${var.region}:${var.account_id}:*"
      ]
      variable = "kms:EncryptionContext:aws:logs:arn"
    }
  }
}
