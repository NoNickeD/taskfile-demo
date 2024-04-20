resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.cluster_name}-${local.name}"
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.worker.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSVPCResourceController,
    aws_security_group.eks-cluster,
  ]
  tags = merge(local.tags, { Name = "${var.cluster_name}" })
}

#-----------------------------------
# EKS Addon
#-----------------------------------
resource "aws_eks_addon" "vpc-cni-addon" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube-proxy-addon" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns-addon" {
  cluster_name                = aws_eks_cluster.eks-cluster.name
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  resolve_conflicts_on_update = "PRESERVE"
}

#-----------------------------------
# IAM 
#-----------------------------------
resource "aws_iam_role" "control_plane" {
  name               = "${var.cluster_name}-control-plane"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "eks-cluster-role" {
  name               = "${var.cluster_name}-eks-role"
  assume_role_policy = aws_iam_role.control_plane.assume_role_policy
  tags               = merge(local.tags, { Name = "${var.cluster_name}-eks-role" })
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-cluster-cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

#-----------------------------------
# Security Group
#-----------------------------------
resource "aws_security_group" "eks-cluster" {
  name        = "${var.cluster_name}-sg-eks-cluster"
  description = "EKS Cluster security group."
  vpc_id      = module.vpc.vpc_id

  # Egress rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.cluster_name}-sg-eks-cluster" })
}

resource "aws_security_group" "worker" {
  name        = "${var.cluster_name}-sg-worker"
  description = "Cluster communication with worker nodes."
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${var.cluster_name}-sg-worker" })
}

#-----------------------------------
# Cloudwatch
#-----------------------------------
resource "aws_cloudwatch_log_group" "eks-cluster-log-group" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}
