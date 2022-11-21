resource "aws_subnet" "public" {
  count                   = var.create_networking_config ? length(var.public_subnet_cidrs) : 0
  cidr_block              = var.public_subnet_cidrs[count.index]
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = true
  availability_zone       = count.index % 2 == 0 ? "${var.region}a" : "${var.region}b"
  tags                    = merge({
    Name = "mwaa-${var.environment_name}-public-subnet-${count.index}"
  }, var.tags)
}

resource "aws_subnet" "private" {
  count                   = var.create_networking_config ? length(var.private_subnet_cidrs) : 0
  cidr_block              = var.private_subnet_cidrs[count.index]
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = false
  availability_zone       = count.index % 2 == 0 ? "${var.region}a" : "${var.region}b"
  tags                    = merge({
    Name = "mwaa-${var.environment_name}-private-subnet-${count.index}"
  }, var.tags)
}

resource "aws_eip" "this" {
  count = var.create_networking_config ? length(var.public_subnet_cidrs) : 0
  vpc   = true
  tags  = merge({
    Name = "mwaa-${var.environment_name}-eip-${count.index}"
  }, var.tags)
}

resource "aws_nat_gateway" "this" {
  count         = var.create_networking_config ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge({
    Name = "mwaa-${var.environment_name}-nat-gateway-${count.index}"
  }, var.tags)
}

resource "aws_internet_gateway" "this" {
  count  = var.create_networking_config && var.internet_gateway_id==null ? 1 : 0
  vpc_id = var.vpc_id
  tags   = merge({
    Name = "mwaa-${var.environment_name}-internet-gateway"
  }, var.tags)
}

resource "aws_route_table" "public" {
  count  = var.create_networking_config ? 1 : 0
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id!=null ? var.internet_gateway_id : aws_internet_gateway.this[0].id
  }
  tags = merge({
    Name = "mwaa-${var.environment_name}-public-routes"
  }, var.tags)
}

resource "aws_route_table_association" "public" {
  count          = var.create_networking_config ? length(aws_subnet.public) : 0
  route_table_id = aws_route_table.public[0].id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_route_table" "private" {
  count  = length(aws_nat_gateway.this)
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }
  tags = merge({
    Name = "mwaa-${var.environment_name}-private-routes-a"
  }, var.tags)
}

resource "aws_route_table_association" "private" {
  count          = var.create_networking_config ?  length(aws_subnet.private) : 0
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
  name   = "mwaa-${var.environment_name}-no-ingress-sg"
  tags   = merge({
    Name = "mwaa-${var.environment_name}-no-ingress-sg"
  }, var.tags  )
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}
