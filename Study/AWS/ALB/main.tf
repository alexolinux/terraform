provider "aws" {
  region = var.region
}

locals {
  name = "aws-study"

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Project   = local.name
    provision = "terraform"
    managedby = "devops"
  }
}

data "aws_availability_zones" "available" {}

# Required VPC Provision
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-${local.name}"
  cidr = local.vpc_cidr

  azs            = ["${var.region}a", "${var.region}b"]
  public_subnets = var.public_subnets

  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  map_public_ip_on_launch = var.map_public_ip_on_launch
  instance_tenancy        = var.instance_tenancy
  create_igw              = var.create_igw

  # Clear Default security group - None ingress/egress rules
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  tags = merge(
    var.default_tags,
    local.tags,
    {
      Environment = "dev"
    }
  )
}

# Security Groups Provision
#-- security-group SSH
resource "aws_security_group" "allows_ssh" {
  name        = "allows_ssh"
  description = "Allows SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH Access for devops sysadmins"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks_ssh
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.default_tags,
    local.tags,
    {
      Name = "allows_ssh",
    }
  )
}

# EC2 Required Resources
#-- Fetch Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

# SSH KeyPair
resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = var.public_key

  tags = merge(
    var.default_tags,
    local.tags,
    {}
  )
}

# Launch Template provision
resource "aws_launch_template" "this" {
  name = "${local.name}-template"

  image_id                             = data.aws_ami.amazon_linux.image_id
  key_name                             = aws_key_pair.this.key_name
  instance_type                        = "t3.micro"
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "terminate"

  network_interfaces {
    associate_public_ip_address = true
  }

  tag_specifications {
    # Specifies the resource type as "instance"
    resource_type = "instance"

    # Tags to apply to the instance
    tags = merge(
      var.default_tags,
      local.tags,
      {
        Name = "${local.name}-template",
      }
    )
  }

  vpc_security_group_ids = [aws_security_group.allows_ssh.id]
  #user_data = filebase64("${path.module}/example.sh")
}