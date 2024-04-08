# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.tags_all,
    {
      "Name" = "public_rt",
      "Tier" = "public"
    }
  )
}

# Public Route Table Association for Subnet 1
resource "aws_route_table_association" "public_rta_subnet1" {
  subnet_id      = aws_subnet.public_us_east_1[0].id
  route_table_id = aws_route_table.public_rt.id
}
# Public Route Table Association for Subnet 2
resource "aws_route_table_association" "public_rta_subnet2" {
  subnet_id      = aws_subnet.public_us_east_1[1].id
  route_table_id = aws_route_table.public_rt.id
}


# Private Route Tables
resource "aws_route_table" "private_rt_1a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }

  tags = merge(
    var.tags_all,
    {
      "Name" = "private_rt_1a",
      "Tier" = "private"
    }
  )
}

resource "aws_route_table" "private_rt_1b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1b.id
  }

  tags = merge(
    var.tags_all,
    {
      "Name" = "private_rt_1b",
      "Tier" = "private"
    }
  )
}

# Private Route Table Association for Subnet 1
resource "aws_route_table_association" "private_rta_subnet1" {
  subnet_id      = aws_subnet.private_us_east_1[0].id
  route_table_id = aws_route_table.private_rt_1a.id
}
# Private Route Table Association for Subnet 2
resource "aws_route_table_association" "private_rta_subnet2" {
  subnet_id      = aws_subnet.private_us_east_1[1].id
  route_table_id = aws_route_table.private_rt_1b.id
}
