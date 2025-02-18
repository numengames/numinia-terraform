resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc.range
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                           = var.vpc.name
    "kubernetes.io/cluster/${var.vpc.name}-cluster" = "shared"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/17"
  availability_zone       = "${var.vpc.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name                                           = "${var.vpc.subnet_name}-a"
    "kubernetes.io/cluster/${var.vpc.name}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.128.0/17"
  availability_zone       = "${var.vpc.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name                                           = "${var.vpc.subnet_name}-b"
    "kubernetes.io/cluster/${var.vpc.name}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = "1"
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

module "security_groups" {
  source   = "./security-groups"
  vpc_id   = aws_vpc.vpc.id
  vpc_name = var.vpc.name
}