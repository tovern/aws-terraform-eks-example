data "aws_availability_zones" "azs" {}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = var.name
    Environment = var.environment
    Product     = var.product
  }
}

resource "aws_subnet" "public" {
  count                   = var.vpc_cidr == "10.0.0.0/16" ? 3 : 0
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  cidr_block              = element(cidrsubnets(var.vpc_cidr, 8, 4, 4), count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "psn-${count.index}"
    Environment = var.environment
    Product     = var.product
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id


  tags = {
    Name        = "igw"
    Environment = var.environment
    Product     = var.product
  }

}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "prt"
    Environment = var.environment
    Product     = var.product
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.public) == 3 ? 3 : 0
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}
