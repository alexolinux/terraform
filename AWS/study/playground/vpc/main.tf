#-- ------------------------------------------------------------------------------
#-- DataSources & Locals
#-- ------------------------------------------------------------------------------

locals {
  cidr = "10.0.0.0/16"

  azs     = slice(data.aws_availability_zones.available.names, 0, 3)
  subnets = cidrsubnets(local.cidr, 3, 3, 3, 4, 4, 4, 5, 5, 5)

  private_subnets  = slice(local.subnets, 0, 3) # /19
  public_subnets   = slice(local.subnets, 3, 6) # /20
  database_subnets = slice(local.subnets, 6, 9) # /21

  name = "playground"
  tags = {
    created     = "devops"
    managed     = "terraform"
    environment = "sandbox"
  }
}

# azs
data "aws_availability_zones" "available" {
  state = "available"
}

# vpc flow_logs 
#data "aws_s3_bucket" "selected" {
#  bucket = "playground-terraform-logs"
#}

#-- ------------------------------------------------------------------------------
#-- Modules & Resources
#-- ------------------------------------------------------------------------------

#-- VPC Resources ----------------------------------------------------------------
module "vpc" {
  source = "../../../modules/vpc"

  name = local.name
  cidr = local.cidr

  azs                     = local.azs              #var.azs
  private_subnets         = local.private_subnets  #var.private_subnets
  database_subnets        = local.database_subnets #var.database_subnets
  public_subnets          = local.public_subnets   #var.public_subnets
  instance_tenancy        = var.instance_tenancy
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  map_public_ip_on_launch = var.map_public_ip_on_launch

  create_database_subnet_route_table = var.create_database_subnet_route_table
  create_database_subnet_group       = var.create_database_subnet_group
  enable_nat_gateway                 = var.enable_nat_gateway
  single_nat_gateway                 = var.single_nat_gateway
  one_nat_gateway_per_az             = var.one_nat_gateway_per_az

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  #enable_flow_log                      = true
  #create_flow_log_cloudwatch_log_group = true
  #create_flow_log_cloudwatch_iam_role  = true
  #flow_log_destination_type            = "s3"
  #flow_log_destination_arn             = data.aws_s3_bucket.selected.arn
  #flow_log_traffic_type                = "REJECT"
  #flow_log_max_aggregation_interval    = 60

  tags = merge(
    local.tags,
    {

    }
  )
}

#-- ------------------------------------------------------------------------------
#-- security groups
#-- ------------------------------------------------------------------------------

#-- security-group SSH && Bastion ------------------------------------------------
resource "aws_security_group" "allows_ssh" {
  name        = "allows_ssh"
  description = "Allows SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH Access for Cloud DevOps Team"
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
    local.tags,
    {
      Name = "allows_ssh",
    }
  )
}
