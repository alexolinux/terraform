locals {
  private_subnet_cidrs = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnet_cidrs  = ["10.0.64.0/19", "10.0.96.0/19"]
  azs                  = ["us-east-1a", "us-east-1b"]
}

resource "aws_subnet" "private_us_east_1" {
  count = length(local.public_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.private_subnet_cidrs, count.index)
  availability_zone = element(local.azs, count.index)

  tags = merge(
    var.tags_all,
    {
      "Name"                            = "private-${element(local.azs, count.index)}"
      "Tier"                            = "private"
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/demo"      = "owned"
    }
  )

}

resource "aws_subnet" "public_us_east_1" {
  count = length(local.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(local.public_subnet_cidrs, count.index)
  availability_zone       = element(local.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.tags_all,
    {
      "Name"                       = "public-${element(local.azs, count.index)}"
      "Tier"                       = "public"
      "kubernetes.io/role/elb"     = "1"
      "kubernetes.io/cluster/demo" = "owned"
    }
  )
}
