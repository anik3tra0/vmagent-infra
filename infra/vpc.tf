resource "aws_vpc" "prod-env" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = {
    Name  = "environment"
    Value = "production"
  }
}

resource "aws_subnet" "subnet-uno" {
  cidr_block        = cidrsubnet(aws_vpc.prod-env.cidr_block, 3, 1)
  vpc_id            = aws_vpc.prod-env.id
  availability_zone = "ap-south-1a"
}

resource "aws_route_table" "route-table-prod-env" {
  vpc_id = aws_vpc.prod-env.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-env-gw.id
  }

  tags = {
    Name  = "environment"
    Value = "production"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet-uno.id
  route_table_id = aws_route_table.route-table-prod-env.id
}

resource "aws_internet_gateway" "prod-env-gw" {
  vpc_id = aws_vpc.prod-env.id
  tags   = {
    Name = "prod-env-gw"
  }
}
