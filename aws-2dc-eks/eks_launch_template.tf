

data "aws_ami" "dc1_ubuntu" {
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

data "aws_ami" "dc2_ubuntu" {
  provider = aws.dc2
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


# TODO

resource "aws_launch_template" "dc1_eks_instance" {
  name = "${var.name}-eks-instance"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 100
      volume_type = "gp2"
    }
  }


  image_id = "ami-0da7cdd9d693ada5f"
#   image_id = data.aws_ami.dc1_ubuntu.id

  instance_type = "t3.medium"

  # See "Configure the user data for your worker nodes" in
  # https://repost.aws/knowledge-center/eks-worker-nodes-cluster
    # user_data = (base64encode("#!/bin/bash\nset -o xtrace\n/etc/eks/bootstrap.sh ${aws_eks_cluster.dc1_eks.id}"
    # ))
  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
/etc/eks/bootstrap.sh ${aws_eks_cluster.dc1_eks.id}
--==MYBOUNDARY==--\
  EOF
  )

#   network_interfaces {
#     security_groups = [
#         aws_security_group.dc2_to_dc1_traffic.id,
#         aws_eks_cluster.dc1_eks.vpc_config[0].cluster_security_group_id]
#   }

  # However, if you want to use your own custom security groups, 
  # you have to include both the custom security group that you want AND 
  # the default EKS Cluster’s security group in order to allow the necessary network connections.
#   vpc_security_group_ids = [
#     aws_security_group.dc2_to_dc1_traffic.id,
#     aws_eks_cluster.dc1_eks.vpc_config[0].cluster_security_group_id,
#   ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-dc1-eks-instance"
        "kubernetes.io/cluster/${aws_eks_cluster.dc1_eks.id}" = "owned"
    }
  }
}

output "aws_eks_cluster_dc1_eks_vpc_config" {
  value = aws_eks_cluster.dc1_eks.vpc_config
}