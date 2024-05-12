resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.range

  tags = {
    Name = var.vpc.name
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.vpc.region}a"

  tags = {
    Name = "${var.vpc.subnet_name}-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.vpc.region}b"

  tags = {
    Name = "${var.vpc.subnet_name}-b"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.vpc.igw_name
  }
}

resource "aws_route" "route_to_igw" {
  destination_cidr_block = var.vpc.igw_cidr_block
  route_table_id         = aws_vpc.vpc.main_route_table_id
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}