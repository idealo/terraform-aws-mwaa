variable "region" {}
variable "account_id" {}
variable "environment_name" {}

variable "sns_subscription_email_address" {}
variable "alert_hook_url" {}

variable "vpc_id" {}
variable "internet_gateway_id" {}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}

variable "s3_bucket" {}
variable "dag_s3_path" {}
variable "requirements_s3_path" {}
variable "additional_execution_role_policy_document_json" {}

variable "max_workers" {
  default = "10"
}

variable "min_workers" {
  default = "1"
}

variable "environment_class" {
  default = "mw1.small"
}

variable "airflow_version" {}

variable "tags" {
  type = map(string)
}
