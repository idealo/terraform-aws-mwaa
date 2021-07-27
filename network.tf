/*
This module deploys a VPC, with a pair of public and private subnets spread
across two Availability Zones. It deploys an internet gateway, with a default
route on the public subnets. It deploys a pair of NAT gateways (one in each
AZ), and default routes for them in the private subnets.
*/

resource "aws_subnet" "mwaa_public_subnet" {
  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  vpc_id = var.vpc_id
  map_public_ip_on_launch = true
  availability_zone = count.index % 2 == 0 ? "${var.region}a" : "${var.region}b"
  tags = merge({
    Name = "mwaa-${var.environment_name}-public-subnet-${count.index}"
  }, var.tags)
}

resource "aws_subnet" "mwaa_private_subnet" {
  count = length( var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  vpc_id = var.vpc_id
  map_public_ip_on_launch = false
  availability_zone = count.index % 2 == 0 ? "${var.region}a" : "${var.region}b"
  tags = merge({
    Name = "mwaa-${var.environment_name}-private-subnet-${count.index}"
  }, var.tags)
}

resource "aws_eip" "mwaa_eip" {
  count = length(var.public_subnet_cidrs)
  vpc = true
  tags = merge({
    Name = "mwaa-${var.environment_name}-eip-${count.index}"
  }, var.tags)
}

resource "aws_nat_gateway" "mwaa_nat_gateway" {
  count = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.mwaa_eip[count.index].id
  subnet_id = aws_subnet.mwaa_public_subnet[count.index].id
  tags = merge({
    Name = "mwaa-${var.environment_name}-nat-gateway-${count.index}"
  }, var.tags)
}

resource "aws_route_table" "mwaa_route_table_public" {
  vpc_id = var.vpc_id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
  tags = merge({
    Name = "mwaa-${var.environment_name}-public-routes"
  }, var.tags)
}

resource "aws_route_table_association" "mwaa_route_table_association_public" {
  count = length(aws_subnet.mwaa_public_subnet)
  route_table_id = aws_route_table.mwaa_route_table_public.id
  subnet_id = aws_subnet.mwaa_public_subnet[count.index].id
}

resource "aws_route_table" "mwaa_route_table_private" {
  count = length(aws_nat_gateway.mwaa_nat_gateway)
  vpc_id = var.vpc_id
  route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mwaa_nat_gateway[count.index].id
  }
  tags = merge({
    Name = "mwaa-${var.environment_name}-private-routes-a"
  }, var.tags)
}

resource "aws_route_table_association" "mwaa_route_table_association_private" {
  count = length(aws_subnet.mwaa_private_subnet)
  route_table_id = aws_route_table.mwaa_route_table_private[count.index].id
  subnet_id = aws_subnet.mwaa_private_subnet[count.index].id
}

resource "aws_security_group" "mwaa_no_ingress_sg" {
  vpc_id = var.vpc_id
  name = "mwaa-${var.environment_name}-no-ingress-sg"
  tags = merge({
    Name = "mwaa-${var.environment_name}-no-ingress-sg"
  }, var.tags  )
}
