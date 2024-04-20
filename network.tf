module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name = "${var.name}-${local.name}"
  cidr = var.cidr_block

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.cidr_block, 4, k)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(var.cidr_block, 8, k + 48)]
  intra_subnets    = [for k, v in local.azs : cidrsubnet(var.cidr_block, 8, k + 52)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.cidr_block, 8, k + 56)]

  private_subnet_names  = [for k, v in local.azs : "${local.name}-private-${k}"]
  public_subnet_names   = [for k, v in local.azs : "${local.name}-public-${k}"]
  intra_subnet_names    = [for k, v in local.azs : "${local.name}-intra-${k}"]
  database_subnet_names = [for k, v in local.azs : "${local.name}-database-${k}"]


  manage_default_security_group = true
  manage_default_route_table    = true
  manage_default_network_acl    = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  flow_log_max_aggregation_interval    = 60


  public_subnet_tags = {
    "kubrnetes.io/role/elb"                           = 1
    "kubernetes.io/cluster/${var.name}-${local.name}" = "owned"
  }

  private_subnet_tags = {
    "kubrnetes.io/role/internal-elb"                  = 1
    "kubernetes.io/cluster/${var.name}-${local.name}" = "owned"
  }

  tags = merge(local.tags, { Name = "${var.name}-vpc" })

}

#-----------------------------------
# IAM Role
#-----------------------------------
resource "aws_iam_policy" "additional" {
  name = "${local.name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
