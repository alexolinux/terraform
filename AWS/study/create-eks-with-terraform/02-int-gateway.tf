resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags_all,
    {
      Name = "igw"
    }
  )
}

output "igw_id" {
  value       = aws_internet_gateway.igw.id
  description = "IGW ID"
}
