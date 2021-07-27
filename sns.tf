resource "aws_sns_topic" "sns-topic" {
  name = "${var.environment_name}-mwaa-sns-topic"
  tags = merge({
    Name = "${var.environment_name}-mwaa-sns-topic"
  }, var.tags)
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

resource "aws_sns_topic_subscription" "sns_email_target" {
  topic_arn = aws_sns_topic.sns-topic.arn
  protocol = "email"
  endpoint = var.sns_subscription_email_address
}

resource "aws_sns_topic_subscription" "sns_lambda_target" {
  topic_arn = aws_sns_topic.sns-topic.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.lambda_alert_notification.arn
}