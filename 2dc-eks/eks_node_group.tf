
data "aws_ami" "ubuntu" {
  provider = aws.dc1
  owners   = ["amazon"]

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# resource "aws_eks_node_group" "dc1_node_group" {
#   cluster_name    = aws_eks_cluster.dc1_eks.name
#   node_group_name = "${var.name}-dc1-eks-node-grp"
#   node_role_arn   = aws_iam_role.eks_node_role.arn
#   subnet_ids      = values(aws_subnet.dc1-private)[*].id

#   scaling_config {
#     desired_size = 2
#     max_size     = 2
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

# #   ami_type       = data.aws_ami.ubuntu.id
#   disk_size      = 100
#   instance_types = ["r5.large"]

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_eks_cluster.dc1_eks,
#   ]
# }

# resource "aws_eks_node_group" "dc2_node_group" {
#   cluster_name    = aws_eks_cluster.dc2_eks.name
#   node_group_name = "${var.name}-dc2-eks-node-grp"
#   node_role_arn   = aws_iam_role.eks_node_role.arn
#   subnet_ids      = values(aws_subnet.dc2-private)[*].id

#   scaling_config {
#     desired_size = 2
#     max_size     = 2
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_eks_cluster.dc2_eks,
#   ]
# }