# general information
variable "region" {}
variable "account_id" {}
variable "environment_name" {}
variable "airflow_version" {
  type = string
  default = "2.0.2"
}

# s3 configuration
variable "s3_bucket" {}
variable "dag_s3_path" {
  type = string
  default = "/dags"
}
variable "plugins_s3_path" {
  default = null
}
variable "plugins_s3_object_version" {
  default = null
}
variable "requirements_s3_path" {
  default = null
}
variable "requirements_s3_object_version" {
  default = null
}

# airflow.cfg values
variable "airflow_configuration_options" {
  type = map(string)
  default = {}
}

# networking
variable "vpc_id" {}
variable "internet_gateway_id" {}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}

variable "additional_execution_role_policy_document_json" {
  type = string
  default = "{}"
}

variable "max_workers" {
  default = "10"
}

variable "min_workers" {
  default = "1"
}

variable "environment_class" {
  default = "mw1.small"
}

variable "webserver_access_mode" {
  type = string
  default = null
}

variable "tags" {
  type = map(string)
}
