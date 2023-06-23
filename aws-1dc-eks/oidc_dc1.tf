data "tls_certificate" "dc1_cluster" {
  url = aws_eks_cluster.dc1_eks.identity.0.oidc.0.issuer
}

### OIDC config
resource "aws_iam_openid_connect_provider" "dc1_cluster" {
  provider        = aws.dc1
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.dc1_cluster.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.dc1_eks.identity.0.oidc.0.issuer
}
