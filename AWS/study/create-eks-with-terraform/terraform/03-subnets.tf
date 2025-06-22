locals {
  eks_cluster_tag_map = { for name in var.eks_names : "kubernetes.io/cluster/${name}" => "owned" }
}

resource "aws_subnet" "private_us_east_1" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(
    var.tags_all,
    {
      "Name"                                  = "private-${element(var.azs, count.index)}"
      "Tier"                                  = "private"
      "kubernetes.io/role/internal-elb"       = "1"
      "kubernetes.io/cluster/${var.eks_name}" = "owned"
      "karpenter.sh/discovery"                = var.eks_names[0]
    }
  )
}

resource "aws_subnet" "public_us_east_1" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.tags_all,
    {
      "Name"                                  = "public-${element(var.azs, count.index)}"
      "Tier"                                  = "public"
      "kubernetes.io/role/elb"                = "1"
      "kubernetes.io/cluster/${var.eks_name}" = "owned"
    }
  )
}

output "private_subnets" {
  value = aws_subnet.private_us_east_1[*].cidr_block
}

output "public_subnets" {
  value = aws_subnet.public_us_east_1[*].cidr_block
}
