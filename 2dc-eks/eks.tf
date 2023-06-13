

# resource "aws_eks_addon" "dc1_coredns" {
#   provider      = aws.dc1
#   cluster_name  = aws_eks_cluster.dc1_eks.name
#   addon_name    = "coredns"
#   addon_version = "v1.10.1-eksbuild.1"
#   depends_on = [
#     aws_eks_node_group.dc1_node_group
#   ]
# }

# resource "aws_eks_addon" "dc2_coredns" {
#   provider      = aws.dc2
#   cluster_name  = aws_eks_cluster.dc2_eks.name
#   addon_name    = "coredns"
#   addon_version = "v1.10.1-eksbuild.1"

#   depends_on = [
#     aws_eks_node_group.dc2_node_group
#   ]
# }

resource "aws_eks_cluster" "dc1_eks" {
  provider = aws.dc1
  name     = "${var.name}-dc1-eks"
  role_arn = aws_iam_role.dc1_eks_cluster_role.arn
  version  = "1.27"

  vpc_config {
    subnet_ids              = values(aws_subnet.dc1-private)[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.dc1_eks_cluster_role
  ]
}


resource "aws_eks_cluster" "dc2_eks" {
  provider = aws.dc2
  name     = "${var.name}-dc2-eks"
  role_arn = aws_iam_role.dc1_eks_cluster_role.arn
  version  = "1.27"

  vpc_config {
    subnet_ids              = values(aws_subnet.dc2-private)[*].id
    endpoint_private_access = true
    endpoint_public_access  = true

  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.dc1_eks_cluster_role
  ]
}

