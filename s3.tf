resource "aws_s3_bucket" "mwaa_airflow_bucket" {
  bucket = "mwaa-${var.environment_name}-${var.account_id}-${var.region}"
  acl = "private"
  versioning {
    enabled = false
  }
  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "mwaa-airflow-bucket-pab" {
  bucket = aws_s3_bucket.mwaa_airflow_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

data "archive_file" "plugins_zip" {
  type        = "zip"
  source_dir = "${path.module}/plugins/"
  output_path = "${path.module}/plugins_${random_id.id.dec}.zip"
}

resource "aws_s3_bucket_object" "mwaa_plugin" {
  bucket = aws_s3_bucket.mwaa_airflow_bucket.bucket
  key    = "plugins/plugins.zip"
  source = data.archive_file.plugins_zip.output_path
  etag = filemd5(data.archive_file.plugins_zip.output_path)
}