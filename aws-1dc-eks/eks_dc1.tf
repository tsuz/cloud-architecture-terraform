

resource "aws_eks_addon" "dc1_coredns" {
  provider          = aws.dc1
  cluster_name      = aws_eks_cluster.dc1_eks.name
  for_each          = { for addon in var.eks_addons : addon.name => addon }
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE" # Be careful

  depends_on = [
    aws_eks_node_group.dc1_node_group
  ]
}

resource "aws_eks_addon" "dc1_csi_addon" {
  provider                 = aws.dc1
  cluster_name             = aws_eks_cluster.dc1_eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.19.0-eksbuild.2"
  service_account_role_arn = aws_iam_role.dc1_csi_driver_role.arn
  depends_on = [
    aws_eks_node_group.dc1_node_group
  ]
}

output "eks_cluster_details" {
  value = aws_eks_cluster.dc1_eks
}

resource "aws_eks_cluster" "dc1_eks" {
  provider = aws.dc1
  name     = "${var.name}-dc1-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.27"

  vpc_config {
    subnet_ids = values(aws_subnet.dc1-private)[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.eks_cluster_role,
  ]
}
