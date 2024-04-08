resource "aws_eip" "eip_nat_1a" {

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    var.tags_all,
    {
      "Name" = "eip_nat_1a"
    }
  )
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.eip_nat_1a.id
  subnet_id     = aws_subnet.public_us_east_1[0].id

  tags = merge(
    var.tags_all,
    {
      "Name" = "nat_1a"
    }
  )
}

resource "aws_eip" "eip_nat_1b" {

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    var.tags_all,
    {
      "Name" = "eip_nat_1b"
    }
  )
}

resource "aws_nat_gateway" "nat_1b" {
  allocation_id = aws_eip.eip_nat_1b.id
  subnet_id     = aws_subnet.public_us_east_1[1].id

  tags = merge(
    var.tags_all,
    {
      "Name" = "nat_1b"
    }
  )
}
