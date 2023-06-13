
# Get current account ID
data "aws_caller_identity" "current" {}

# For creating fargate role
resource "aws_iam_role" "eks_fargate_role_dc1" {
  name = "${var.name}-eks-fargate-role-dc1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Condition": {
         "ArnLike": {
            "aws:SourceArn": "arn:aws:eks:${var.dc1_region}:${data.aws_caller_identity.current.account_id}:fargateprofile/${var.name}-dc1-eks/*"
         }
      },
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  ]

  tags = {
    tag-key = "${var.name}-eks-fargate-role-dc1"
  }
}

# For creating fargate role
resource "aws_iam_role" "eks_fargate_role_dc2" {
  name = "${var.name}-eks-fargate-role-dc2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Condition": {
         "ArnLike": {
            "aws:SourceArn": "arn:aws:eks:${var.dc2_region}:${data.aws_caller_identity.current.account_id}:fargateprofile/${var.name}-dc2-eks/*"
         }
      },
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  ]

  tags = {
    tag-key = "${var.name}-eks-fargate-role-dc2"
  }
}

resource "aws_eks_fargate_profile" "dc1_kube_system" {
  provider               = aws.dc1
  cluster_name           = aws_eks_cluster.dc1_eks.name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role_dc1.arn

  subnet_ids = values(aws_subnet.dc1-private)[*].id

  selector {
    namespace = "kube-system"
  }
}

resource "aws_eks_fargate_profile" "dc2_kube_system" {
  provider               = aws.dc2
  cluster_name           = aws_eks_cluster.dc2_eks.name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role_dc2.arn

  subnet_ids = values(aws_subnet.dc2-private)[*].id

  selector {
    namespace = "kube-system"
  }
}
