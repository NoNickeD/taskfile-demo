#-----------------------------------
# EKS Node Group (workers)
#-----------------------------------
resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.worker-role.arn
  version         = var.cluster_version
  subnet_ids      = module.vpc.private_subnets
  instance_types  = var.instance_types
  disk_size       = var.disk_size
  ami_type        = var.ami_type

  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_count_max
    min_size     = var.node_count_min
  }
  depends_on = [
    aws_iam_role_policy_attachment.worker-role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker-role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.worker-role-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = merge(local.tags, { Name = "${var.cluster_name}-node-group" })
}

#-----------------------------------
# IAM Role Policy Attachments
#-----------------------------------
resource "aws_iam_role" "worker-role" {
  name = "${var.cluster_name}-worker-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "worker-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "worker-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "worker-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "worker-role-SSMCore" {
  role       = aws_iam_role.worker-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "worker-role-AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.worker-role.name
}


