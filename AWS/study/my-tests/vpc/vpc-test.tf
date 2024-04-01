# terraform provision

locals {
  project = "testing"
  name    = "vpc-test"

  availability_zones = ["us-east-1b", "us-east-1c"]

  public_subnet_cidrs = [
    for i in range(var.public_subnet_count) : "10.0.${i * 16}.0/24"
  ]

  private_subnet_cidrs = [
    for i in range(var.private_subnet_count) : "10.0.${(i + var.public_subnet_count) * 16}.0/24"
  ]

  database_subnet_cidrs = [
    for i in range(var.database_subnet_count) : "10.0.${(i + var.public_subnet_count + var.private_subnet_count) * 16}.0/24"
  ]
}

# -- AWS VPC -------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.tags,
    {
      Name    = "${local.name}",
      project = local.project
    }
  )
}

#-- AWS Subnets -------------------------------------------
resource "aws_subnet" "public" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = element(local.availability_zones, count.index % length(local.availability_zones))
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      Name = "public-subnet-${count.index + 1}"
    }
  )

}

resource "aws_subnet" "private" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = element(local.availability_zones, (count.index + var.public_subnet_count) % length(local.availability_zones))

  tags = merge(
    var.tags,
    {
      Name = "private-subnet-${count.index + 1}"
    }
  )
}

resource "aws_subnet" "database" {
  count = var.database_subnet_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.database_subnet_cidrs[count.index]
  availability_zone = element(local.availability_zones, (count.index + var.public_subnet_count + var.private_subnet_count) % length(local.availability_zones))

  tags = merge(
    var.tags,
    {
      Name = "database-subnet-${count.index + 1}"
    }
  )
}

#-- Internet Gateway for Public Routing -------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "igw-${local.name}"
    }
  )
}

# Route Table for Public Subnets - IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    {
      Name = "public-rt-${local.name}"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*])
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

#-- NAT Gateway for Private Routing -------------------------------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    var.tags,
    {
      Name = "nat-eip-${local.name}"
    }
  )
}

resource "aws_nat_gateway" "single_nat" {
  count         = var.enable_nat_gateway ? 1 : 0
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.nat_eip.id

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    var.tags,
    {
      Name = "single-nat-${local.name}"
    }
  )
}


# Route Table for Public Subnets - IGW
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.single_nat[0].id
  }

  tags = merge(
    var.tags,
    {
      Name = "private-rt-${local.name}"
    }
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private[*])
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
