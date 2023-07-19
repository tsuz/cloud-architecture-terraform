
# TODO

# resource "aws_eks_fargate_profile" "dc1" {
#   provider               = aws.dc1
#   cluster_name           = aws_eks_cluster.dc1_eks.name
#   fargate_profile_name   = "dc1"
#   pod_execution_role_arn = aws_iam_role.eks_fargate_role_dc1.arn

#   subnet_ids = values(aws_subnet.dc1-private)[*].id

#   selector {
#     namespace = "dc1"
#     labels    = { "k8s-app" : "kube-dns", "confluent-platform": true}
#   }
# }

# resource "aws_eks_fargate_profile" "dc2" {
#   provider               = aws.dc2
#   cluster_name           = aws_eks_cluster.dc2_eks.name
#   fargate_profile_name   = "dc2"
#   pod_execution_role_arn = aws_iam_role.eks_fargate_role_dc2.arn

#   subnet_ids = values(aws_subnet.dc2-private)[*].id

#   selector {
#     namespace = "dc2"
#     labels    = { "k8s-app" : "kube-dns" }
#   }
# }
