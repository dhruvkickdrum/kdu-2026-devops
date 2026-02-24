data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  base_tags = {
    Environment = var.environment
    Creator     = var.prefname
    Purpose     = var.purpose
  }

  public_azs = slice(data.aws_availability_zones.available.names, 0, 2)
  app_az     = local.public_azs[0]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-igw"
  })
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.public_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-public-subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "private_app" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_app_subnet_cidrs[0]
  availability_zone       = local.app_az
  map_public_ip_on_launch = false

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-private-app-subnet-1"
  })
}

resource "aws_subnet" "db" {
  count                   = length(var.db_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.db_subnet_cidrs[count.index]
  availability_zone       = local.public_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-db-subnet-${count.index + 1}"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-nat-eip-1"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-nat-gateway-1"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-public-rt"
  })
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-private-app-rt"
  })
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-db-rt"
  })
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  subnet_id      = aws_subnet.private_app.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}
