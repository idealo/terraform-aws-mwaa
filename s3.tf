data "archive_file" "plugins_zip" {
  type        = "zip"
  source_dir = "${path.module}/plugins/"
  output_path = "${path.module}/plugins_${random_id.id.dec}.zip"
}

data "aws_s3_bucket" "mwaa_bucket" {
  bucket = var.s3_bucket
}

resource "aws_s3_bucket_object" "mwaa_plugin" {
  bucket = var.s3_bucket
  key    = "plugins/plugins.zip"
  source = data.archive_file.plugins_zip.output_path
  etag = filemd5(data.archive_file.plugins_zip.output_path)
}
