output "mwaa_arn" {
  value = aws_mwaa_environment.this.arn
}

output "mwaa_nat_gateway_public_ips" {
  value = aws_nat_gateway.this[*].public_ip
  description = "List of the ips of the nat gateways created by this module."
}
