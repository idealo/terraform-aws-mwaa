resource "aws_iam_role" "mwaa_execution_role" {
  name = "mwaa-${var.environment_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.mwaa_assume_role_policy-doc.json
  tags = var.tags
}

resource "aws_iam_role_policy" "mwaa_execution_policy" {
  name = "mwaa-${var.environment_name}-execution-policy"
  policy = data.aws_iam_policy_document.mwaa_execution_policy-doc.json
  role = aws_iam_role.mwaa_execution_role.id
}

data "aws_iam_policy_document" "mwaa_assume_role_policy-doc" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = [
        "airflow-env.amazonaws.com",
        "airflow.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "mwaa_execution_policy-doc-basic" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "airflow:PublishMetrics"
    ]
    resources = [
      "arn:aws:airflow:${var.region}:${var.account_id}:environment/${var.environment_name}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]
    resources = [
      aws_s3_bucket.mwaa_airflow_bucket.arn,
      "${aws_s3_bucket.mwaa_airflow_bucket.arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:airflow-${var.environment_name}-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }
  statement {

    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:*:airflow-celery-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    not_resources = [
      "arn:aws:kms:*:${var.account_id}:key/*"
    ]
    condition {
      test = "StringLike"
      values = [
        "sqs.eu-central-1.amazonaws.com"]
      variable = "kms:ViaService"
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "SNS:Publish"
    ]
    resources = [
      "arn:aws:sns:${var.region}:*:${var.environment_name}-mwaa-sns-topic"
    ]
  }
}

data "aws_iam_policy_document" "mwaa_execution_policy-doc" {
  source_policy_documents = [
    data.aws_iam_policy_document.mwaa_execution_policy-doc-basic.json,
    var.additional_execution_role_policy_document_json
  ]
}
