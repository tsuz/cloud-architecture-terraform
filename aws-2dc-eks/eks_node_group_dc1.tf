

resource "aws_eks_node_group" "dc1_node_group" {
  provider        = aws.dc1
  cluster_name    = aws_eks_cluster.dc1_eks.name
  node_group_name = "${var.name}-dc1-eks-node-grp"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = values(aws_subnet.dc1-private)[*].id

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 0
  }

  disk_size      = 100
  instance_types = ["r5.large"]

  # launch_template {
  #   id      = aws_launch_template.dc1_eks_instance.id
  #   version = "$Latest"
  # }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.dc1_eks,
    aws_launch_template.dc1_eks_instance,
    aws_iam_role.eks_node_role,
  ]

  # lifecycle {
  #   create_before_destroy = true
  # }
}
