output "mwaa_arn" {
  value       = aws_mwaa_environment.this.arn
  description = "The arn of the created MWAA environment."
}

output "mwaa_execution_role_arn" {
  value = aws_mwaa_environment.this.execution_role_arn
  description = "The IAM Role arn for MWAA Execution Role."
}

output "mwaa_service_role_arn" {
  value = aws_mwaa_environment.this.execution_role_arn
  description = "The Service Role arn for MWAA environment."
}

output "mwaa_nat_gateway_public_ips" {
  value       = aws_nat_gateway.this[*].public_ip
  description = "List of the ips of the nat gateways created by this module."
}

output "mwaa_webserver_url" {
  value       = aws_mwaa_environment.this.webserver_url
  description = "The webserver URL of the MWAA Environment."
}
