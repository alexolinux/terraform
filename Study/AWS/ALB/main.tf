provider "aws" {
  region = var.region
}

locals {
  name = "aws-study"

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Project     = local.name
    Environment = "dev"
    provision   = "terraform"
    managedby   = "devops"
  }
}

data "aws_availability_zones" "available" {}

# Required VPC Provision
#https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
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
    {}
  )
}

# Security Groups Provision
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group.html
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

#-- security-group ALB
resource "aws_security_group" "allows_alb" {
  name        = "allows_alb"
  description = "Load Balancer security group"
  vpc_id      = module.vpc.vpc_id

  # Inbound Traffic
  ingress {
    description = "HTTPS Rule"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks_alb
  }

  ingress {
    description = "HTTP Rule"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks_alb
  }

  # Outbound traffic
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
      Name = "allows_alb",
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
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "this" {
  name = "${local.name}-template"

  image_id                             = data.aws_ami.amazon_linux.image_id
  key_name                             = aws_key_pair.this.key_name
  instance_type                        = "t3.micro"
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "terminate"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allows_ssh.id]
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

  #vpc_security_group_ids = [aws_security_group.allows_alb.id]
  user_data = filebase64("./files/bootstrap.sh")
  # user_data = <<-EOF
  #   #!/bin/bash
  #   yum update -y
  #   yum install -y nginx
  #   echo "<html><body><h2>EC2 Hostname: \$(hostname)</h2></body></html>" > /usr/share/nginx/html/index.html
  #   systemctl enable --now nginx
  # EOF
}

# Auto Scaling Group
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "this" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 2
  # Original vpc_zone_identifier : aws_subnet.example_subnets[*].id
  vpc_zone_identifier = module.vpc.public_subnets
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  wait_for_capacity_timeout = "0"
  protect_from_scale_in     = false

}

# Application Load Balancer
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "this" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allows_alb.id]
  subnets            = module.vpc.public_subnets #[for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  # ALB Tags
  tags = merge(
    var.default_tags,
    local.tags,
    {
      Name = "${local.name}-alb",
    }
  )
}

# ALB Target Group
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "this" {
  name        = "${local.name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id #aws_vpc.main.id

  health_check {
    path                = "/index.html"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  # Target Group Tags
  tags = merge(
    var.default_tags,
    local.tags,
    {
      Name = "${local.name}-alb-tg",
    }
  )
}

# ALB Target Group Attachment
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_autoscaling_group.this.id
}

# Listener to ALB
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
# resource "aws_lb_listener" "this" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.this.arn
#   }
# }
