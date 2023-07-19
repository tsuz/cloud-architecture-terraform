

resource "aws_iam_role_policy" "dc2_loadbalancer_role_policy" {
  provider = aws.dc2
  name     = "${var.name}-dc2-loadbalancer_custom_policy"
  role     = aws_iam_role.dc2_loadbalancer_role.id

  policy = (data.http.loadbalancer_iam_policy.response_body)
}

# IAM policy that can make calls to AWS APIs on behalf
resource "aws_iam_role" "dc2_loadbalancer_role" {
  provider = aws.dc2
  name     = "${var.name}-eks-dc2-loadbalancer-role"

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
                    "${split("oidc-provider/", aws_iam_openid_connect_provider.dc2_cluster.arn)[1]}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}

EOF

  tags = {
    tag-key = "${var.name}-eks-dc2-loadbalancer-role"
  }
}
