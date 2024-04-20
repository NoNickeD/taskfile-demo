data "aws_availability_zones" "available" {
  state = "available"
}

# Get the latest EKS optimized AMI release version
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com", "eks-fargate-pods.amazonaws.com", "eks-nodegroup.amazonaws.com", "lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Get the latest EKS optimized AMI release version
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks-cluster.version}/amazon-linux-2/recommended/release_version"
}

# Get the latest EKS optimized AMI ID
data "tls_certificate" "eks-cluster-cert" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}

# Get the current AWS region
data "aws_region" "current" {}
