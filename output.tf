#-----------------------------------
# VPC Outputs
#-----------------------------------
output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "gateway_id" {
  value = module.vpc.public_internet_gateway_route_id
}

#-----------------------------------
# EKS Outputs
#-----------------------------------
output "eks-endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}


output "eks-cluster-name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "eks-cluster-arn" {
  value = aws_eks_cluster.eks-cluster.arn
}

output "eks-cluster-endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}


#-----------------------------------
# ECR Outputs
#-----------------------------------
output "ecr-repository" {
  value = aws_ecr_repository.ecr-repository.name
}

output "ecr-repository-url" {
  value = aws_ecr_repository.ecr-repository.repository_url
}

#-----------------------------------
# Load Balancer Outputs
#-----------------------------------

output "alb_dns_name" {
  value = aws_lb.eks_alb.dns_name
}
