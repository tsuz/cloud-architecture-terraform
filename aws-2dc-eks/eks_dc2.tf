

resource "aws_eks_addon" "dc2_coredns" {
  provider          = aws.dc2
  cluster_name      = aws_eks_cluster.dc2_eks.name
  for_each          = { for addon in var.eks_addons : addon.name => addon }
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE" # Be careful

  depends_on = [
    aws_eks_node_group.dc2_node_group
  ]
}

resource "aws_eks_addon" "dc2_csi_addon" {
  provider                 = aws.dc2
  cluster_name             = aws_eks_cluster.dc2_eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.19.0-eksbuild.2"
  service_account_role_arn = aws_iam_role.dc2_csi_driver_role.arn
  depends_on = [
    aws_eks_node_group.dc2_node_group
  ]
}

resource "aws_eks_cluster" "dc2_eks" {
  provider = aws.dc2
  name     = "${var.name}-dc2-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.27"

  vpc_config {
    subnet_ids              = values(aws_subnet.dc2-private)[*].id
    security_group_ids      = [aws_security_group.dc1_to_dc2_traffic.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_security_group.dc1_to_dc2_traffic
  ]
}

output "aws_eks_cluster_dc2_name" {
  value = aws_eks_cluster.dc2_eks.name
}

resource "aws_security_group" "dc1_to_dc2_traffic" {
  provider    = aws.dc2
  name        = "dc1_to_dc2_traffic"
  description = "Allow traffic from DC1 to DC2"
  vpc_id      = aws_vpc.dc2.id

  ingress {
    cidr_blocks = [var.dc1_vpc_cidr_block]
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
  }

  tags = {
    Name = "${var.name}-eks-dc1-to-dc2-traffic"
  }
}