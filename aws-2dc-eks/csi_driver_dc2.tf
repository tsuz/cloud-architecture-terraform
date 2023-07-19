

# For creating EKS cluster
resource "aws_iam_role" "dc2_csi_driver_role" {
  provider = aws.dc2
  name     = "${var.name}-dc2-eks-csi-driver-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${aws_iam_openid_connect_provider.dc2_cluster.arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${split("oidc-provider/", aws_iam_openid_connect_provider.dc2_cluster.arn)[1]}:aud": "sts.amazonaws.com",
                    "${split("oidc-provider/", aws_iam_openid_connect_provider.dc2_cluster.arn)[1]}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                }
            }
        }
    ]
}
EOF


  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
  ]

  tags = {
    tag-key = "${var.name}-dc2-eks-csi-driver-role"
  }
}

