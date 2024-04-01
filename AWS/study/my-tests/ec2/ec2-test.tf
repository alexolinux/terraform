
#-- locals
locals {
  project  = "testing"
  vpc_name = "vpc-test"
  name     = "ec2-test"
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  cidr_blocks_ssh = ["0.0.0.0/0"]

  tags = {
    Project     = local.project
    Environment = "dev"
    managed     = "terraform"
    createdby   = "devops"
  }
}

#-- data
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet-1", "public-subnet-2"]
  }
}

#-- Fetch data: Availability Zones
data "aws_availability_zones" "available" {}

#-- ami-08b46fd32a1a5be7f
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.3*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM AWS Managed Policy & AWS User IAM Role for ec2 instance
data "aws_iam_policy" "selected" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "iam_instance_core" {
  name = "SSMManagedInstanceCore"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "iam_attachment" {
  role       = aws_iam_role.iam_instance_core.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Required for ec2 resource
resource "aws_iam_instance_profile" "instance_profile" {
  name = "EC2InstanceProfileSSMCore"
  role = aws_iam_role.iam_instance_core.name
}

#-- resource

# security-group SSH
resource "aws_security_group" "ec2" {
  name        = "ec2"
  description = "EC2 Security Group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "SSH Access for devops sysadmins"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.cidr_blocks_ssh
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "allows_ec2",
    }
  )

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "2m"
  }

  depends_on = [
    data.aws_vpc.selected
  ]

}

# Additional SG Rule for Jenkins Access
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  description       = "Access for Jenkins on 8080"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_key_pair" "this" {
  key_name   = "keypair-${local.name}"
  public_key = var.public_key
}

# ec2 instance resource
resource "aws_instance" "this" {
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.this.id
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Provisioner connection
  connection {
    type        = "ssh"
    user        = var.user_name
    private_key = file("${var.private_key}")
    host        = self.public_ip
  }

  # User Data Automation script
  user_data = file("./files/bootstrap.sh")

  tags = merge(
    local.tags,
    {
      Name = local.name
    }
  )

  lifecycle {
    # Reference the security group as a whole or 
    # individual attributes like `name`
    replace_triggered_by = [aws_security_group.ec2]
  }

  depends_on = [
    data.aws_vpc.selected,
    aws_security_group.ec2
  ]
}
