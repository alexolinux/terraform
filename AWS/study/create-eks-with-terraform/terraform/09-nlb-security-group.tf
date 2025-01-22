resource "aws_security_group" "nlb_sg" {
  name        = "lb-app-sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags_all,
    {
      "Name" = "lb-app-sg"
    }
  )
}

output "nlb_sg_id" {
  value = aws_security_group.nlb_sg.id
}
