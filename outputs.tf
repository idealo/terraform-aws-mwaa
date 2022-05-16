output "mwaa_arn" {
  value = aws_mwaa_environment.this.arn
}

output "mwaa_nat_gateway_public_ips" {
  value = [ for nat_gateway in aws_nat_gateway.this: nat_gateway.public_ip ]
  description = "List of the ips of the nat gateways created by this module."
}
