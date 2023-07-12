
data "http" "loadbalancer_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_role_policy" "dc1_loadbalancer_role_policy" {
  provider = aws.dc1
  name     = "${var.name}-dc1-loadbalancer_custom_policy"
  role     = aws_iam_role.dc1_loadbalancer_role.id

  policy = (data.http.loadbalancer_iam_policy.response_body)
}

# IAM policy that can make calls to AWS APIs on behalf
resource "aws_iam_role" "dc1_loadbalancer_role" {
  name = "${var.name}-eks-dc1-loadbalancer-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${aws_iam_openid_connect_provider.dc1_cluster.arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${split("oidc-provider/", aws_iam_openid_connect_provider.dc1_cluster.arn)[1]}:aud": "sts.amazonaws.com",
                    "${split("oidc-provider/", aws_iam_openid_connect_provider.dc1_cluster.arn)[1]}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}

EOF

  tags = {
    tag-key = "${var.name}-eks-dc1-loadbalancer-role"
  }
}
