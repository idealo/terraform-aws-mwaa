resource "aws_mwaa_environment" "mwaa_environment" {
  airflow_configuration_options = {
    "email.email_backend" = "custom_sns.send_email"
    "email.html_content_template" = "/usr/local/airflow/plugins/custom_email_template.txt"
    "email.subject_template" = "/usr/local/airflow/plugins/custom_subject_template.txt"
  }

  dag_s3_path = var.dag_s3_path
  execution_role_arn = aws_iam_role.mwaa_execution_role.arn
  name = var.environment_name
  max_workers = var.max_workers
  min_workers = var.min_workers
  environment_class = var.environment_class
  plugins_s3_path = aws_s3_bucket_object.mwaa_plugin.key
  requirements_s3_path = var.requirements_s3_path
  airflow_version = var.airflow_version

  logging_configuration {
    dag_processing_logs {
      enabled = true
      log_level = "WARNING"
    }

    scheduler_logs {
      enabled = true
      log_level = "WARNING"
    }

    task_logs {
      enabled = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled = true
      log_level = "WARNING"
    }

    worker_logs {
      enabled = true
      log_level = "WARNING"
    }
  }

  network_configuration {
    security_group_ids = [
      aws_security_group.mwaa_no_ingress_sg.id]
    subnet_ids = aws_subnet.mwaa_private_subnet.id
  }

  source_bucket_arn = aws_s3_bucket.mwaa_airflow_bucket.arn

  webserver_access_mode = "PUBLIC_ONLY"
  tags = merge({
    Name = "mwaa-${var.environment_name}"
  }, var.tags)
}
