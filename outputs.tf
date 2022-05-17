output "mwaa_arn" {
  value = aws_mwaa_environment.this.arn
  description = "The arn of the created MWAA environment"
}
