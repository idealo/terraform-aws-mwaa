# general information
variable "region" {
  type = string
  description = "AWS Region where the environment and its resources will be created"
}
variable "account_id" {
  type = string
  description = "Account ID of the account in which MWAA will be started"
}
variable "environment_name" {
  type = string
  description = "Name of the MWAA environment"
}
variable "airflow_version" {
  description = "Airflow version to be used"
  type = string
  default = "2.0.2"
}

# s3 configuration
variable "source_bucket_arn" {
  type = string
  description = "ARN of the bucket in which DAGs, Plugin and Requirements are put"
}
variable "dag_s3_path" {
  description = "Relative path of the dags folder within the source bucket"
  type = string
  default = "/dags"
}
variable "plugins_s3_path" {
  type = string
  description = "relative path of the plugins.zip within the source bucket"
  default = null
}
variable "plugins_s3_object_version" {
  default = null
}
variable "requirements_s3_path" {
  type = string
  description = "relative path of the requirements.txt (incl. filename) within the source bucket"
  default = null
}
variable "requirements_s3_object_version" {
  default = null
}

# airflow.cfg values
variable "airflow_configuration_options" {
  description = "additional configuration to overwrite airflows standard config"
  type = map(string)
  default = {}
}

# networking
variable "vpc_id" {
  description = "VPC id of the VPC in which the environments resources are created"
}
variable "internet_gateway_id" {
  description = "ID of the internet gateway to the VPC"
}

variable "create_networking_config" {
  description = "true if networking resources (subnets, eip, NAT Gateway and Route table should be created."
  type = bool
  default = true
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets MWAA uses. Must be at least 2"
  type = list(string)
  validation {
    condition = length(var.public_subnet_cidrs) >= 2
    error_message = "You must enter at least 2 CIDR blocks for public subnets if network config is enabled."
  }
}
variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets MWAA uses. Must be at least 2"
  type = list(string)
  default = []
}

# iam
variable "additional_execution_role_policy_document_json" {
  description = "Additional permissions to attach to the base mwaa execution role"
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
  description = "Default: PRIVATE_ONLY"
  type = string
  default = null
}

variable "tags" {
  type = map(string)
  default = {}
}
