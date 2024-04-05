resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags_all,
    {
      Name = "igw"
    }
  )
}
