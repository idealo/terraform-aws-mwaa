# general information
variable "region" {
  type        = string
  description = "AWS Region where the environment and its resources will be created"
}
variable "account_id" {
  type        = string
  description = "Account ID of the account in which MWAA will be started"
}
variable "environment_name" {
  type        = string
  description = "Name of the MWAA environment"
}
variable "airflow_version" {
  description = "Airflow version to be used"
  type        = string
  default     = "2.0.2"
}

# s3 configuration
variable "source_bucket_arn" {
  type        = string
  description = "ARN of the bucket in which DAGs, Plugin and Requirements are put"
}
variable "dag_s3_path" {
  description = "Relative path of the dags folder within the source bucket"
  type        = string
  default     = "dags/"
}
variable "plugins_s3_path" {
  type        = string
  description = "relative path of the plugins.zip within the source bucket"
  default     = null
}
variable "plugins_s3_object_version" {
  default = null
}
variable "requirements_s3_path" {
  type        = string
  description = "relative path of the requirements.txt (incl. filename) within the source bucket"
  default     = null
}
variable "requirements_s3_object_version" {
  default = null
}

# airflow.cfg values
variable "airflow_configuration_options" {
  description = "additional configuration to overwrite airflows standard config"
  type        = map(string)
  default     = {}
}

# networking
variable "vpc_id" {
  description = "VPC id of the VPC in which the environments resources are created"
}
variable "internet_gateway_id" {
  description = "ID of the internet gateway to the VPC"
}

variable "create_networking_config" {
  description = "true if networking resources (subnets, eip, NAT gateway and route table) should be created."
  type        = bool
  default     = true
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets MWAA uses. Must be at least 2 if create_networking_config=true"
  type        = list(string)
  default     = []
}
variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets MWAA uses. Must be at least 2 if create_networking_config=true"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Subnet Ids of the existing private subnets that should be used if create_networking_config=false"
  type        = list(string)
  default     = []
}

# iam
variable "additional_execution_role_policy_document_json" {
  description = "Additional permissions to attach to the base mwaa execution role"
  type        = string
  default     = "{}"
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
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS CMK ARN to use by MWAA for data encryption. MUST reference the same KMS key as used by S3 bucket specified by source_bucket_arn, if the bucket uses KMS. If not specified, the default AWS owned key for MWAA will be used for backward compatibility with version 1.0.1 of this module."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "dag_processing_logs_enabled" {
  type    = bool
  default = true
}

variable "dag_processing_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "WARNING"
}

variable "scheduler_logs_enabled" {
  type    = bool
  default = true
}

variable "scheduler_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "WARNING"
}

variable "task_logs_enabled" {
  type    = bool
  default = true
}

variable "task_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "INFO"
}

variable "webserver_logs_enabled" {
  type    = bool
  default = true
}

variable "webserver_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "WARNING"
}

variable "worker_logs_enabled" {
  type    = bool
  default = true
}

variable "worker_logs_level" {
  type        = string
  description = "One of: DEBUG, INFO, WARNING, ERROR, CRITICAL"
  default     = "WARNING"
}

variable "weekly_maintenance_window_start" {
  type = string
  description = "The day and time of the week in Coordinated Universal Time (UTC) 24-hour standard time to start weekly maintenance updates of your environment in the following format: DAY:HH:MM. For example: TUE:03:30. You can specify a start time in 30 minute increments only"
  default = "MON:01:00"
}
