resource "aws_mwaa_environment" "this" {
  airflow_configuration_options = var.airflow_configuration_options

  execution_role_arn = aws_iam_role.this.arn
  name               = var.environment_name
  max_workers        = var.max_workers
  min_workers        = var.min_workers
  environment_class  = var.environment_class
  airflow_version    = var.airflow_version

  source_bucket_arn                 = var.source_bucket_arn
  dag_s3_path                       = var.dag_s3_path
  plugins_s3_path                   = var.plugins_s3_path
  plugins_s3_object_version         = var.plugins_s3_object_version
  requirements_s3_path              = var.requirements_s3_path
  requirements_s3_object_version    = var.requirements_s3_object_version
  startup_script_s3_path            = var.startup_script_s3_path
  startup_script_s3_object_version  = var.startup_script_s3_object_version

  logging_configuration {
    dag_processing_logs {
      enabled   = var.dag_processing_logs_enabled
      log_level = var.dag_processing_logs_level
    }

    scheduler_logs {
      enabled   = var.scheduler_logs_enabled
      log_level = var.scheduler_logs_level
    }

    task_logs {
      enabled   = var.task_logs_enabled
      log_level = var.task_logs_level
    }

    webserver_logs {
      enabled   = var.webserver_logs_enabled
      log_level = var.webserver_logs_level
    }

    worker_logs {
      enabled   = var.worker_logs_enabled
      log_level = var.worker_logs_level
    }
  }

  network_configuration {
    security_group_ids = concat([aws_security_group.this.id], var.additional_associated_security_group_ids)
    subnet_ids         = var.create_networking_config ? aws_subnet.private[*].id : var.private_subnet_ids
  }

  webserver_access_mode           = var.webserver_access_mode
  weekly_maintenance_window_start = var.weekly_maintenance_window_start

  kms_key = var.kms_key_arn

  tags = merge({
    Name = "mwaa-${var.environment_name}"
  }, var.tags)
}
