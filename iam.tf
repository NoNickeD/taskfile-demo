# Description: This Terraform configuration file creates an IAM role and attaches the AmazonSSMFullAccess policy to it.
resource "aws_iam_role" "ssm_access_role" {
  name = "SSMAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::${var.aws_account_id}:root"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach the AmazonSSMFullAccess policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
