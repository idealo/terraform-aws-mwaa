resource "random_id" "id" {
  keepers = {
    timestamp = timestamp()
    # force change on every execution
  }
  byte_length = 8
}

data "archive_file" "mwaa_teams_alert_notification_zip" {
  type = "zip"
  source_file = "${path.module}/alert-notification-lambda/mwaa_teams_alert_notification.py"
  output_path = "${path.module}/alert-notification-lambda/mwaa_teams_alert_notification_${random_id.id.dec}.zip"
}

resource "aws_lambda_function" "lambda_alert_notification" {
  function_name = "${var.environment_name}-mwaa-alert-notification"
  handler = "mwaa_teams_alert_notification.lambda_handler"
  role = aws_iam_role.mwaa_alert_notification_role.arn
  runtime = "python3.8"
  filename = data.archive_file.mwaa_teams_alert_notification_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.mwaa_teams_alert_notification_zip.output_path)

  environment {
    variables = {
      HookUrl = var.alert_hook_url
    }
  }
  tags = merge({
    Name = "mwaa-teams-alert-notification"
  }, var.tags)
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_alert_notification.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.sns-topic.arn
}

resource "aws_iam_role_policy" "mwaa_alert_notification_policy" {
  name = "${var.environment_name}-mwaa-alert-notification-role-policy"
  role = aws_iam_role.mwaa_alert_notification_role.id
  policy = data.aws_iam_policy_document.mwaa_alert_notification_policy-doc.json
}

resource "aws_iam_role" "mwaa_alert_notification_role" {
  name = "${var.environment_name}-mwaa-alert-notification-role"
  assume_role_policy = data.aws_iam_policy_document.mwaa_alert_notification_assume_role_policy-doc.json
}

data "aws_iam_policy_document" "mwaa_alert_notification_assume_role_policy-doc" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [
        "lambda.amazonaws.com"]
      type = "Service"
    }
    actions = [
      "sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "mwaa_alert_notification_policy-doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${aws_lambda_function.lambda_alert_notification.function_name}:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:*"
    ]
  }
}