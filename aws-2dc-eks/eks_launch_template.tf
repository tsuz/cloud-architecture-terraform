

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

data "aws_ssm_parameter" "dc1_amzn2_ami" {
  provider = aws.dc1
  name     = "/aws/service/eks/optimized-ami/1.27/amazon-linux-2/recommended/image_id"
}

# TODO

resource "aws_launch_template" "dc1_eks_instance" {
  provider = aws.dc1
  name     = "${var.name}-eks-instance"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 100
      volume_type = "gp2"
    }
  }


  image_id = data.aws_ssm_parameter.dc1_amzn2_ami.value

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

  # However, if you want to use your own custom security groups, 
  # you have to include both the custom security group that you want AND 
  # the default EKS Cluster’s security group in order to allow the necessary network connections.
  vpc_security_group_ids = [
    aws_eks_cluster.dc1_eks.vpc_config[0].cluster_security_group_id,
    aws_security_group.dc2_to_dc1_traffic.id,
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                                  = "${var.name}-dc1-eks-instance"
      "kubernetes.io/cluster/${aws_eks_cluster.dc1_eks.id}" = "owned"
    }
  }
}

output "aws_eks_cluster_dc1_eks_vpc_config" {
  value = aws_eks_cluster.dc1_eks.vpc_config
}

data "aws_ssm_parameter" "dc2_amzn2_ami" {
  provider = aws.dc2
  name     = "/aws/service/eks/optimized-ami/1.27/amazon-linux-2/recommended/image_id"
}

output "dc2_ami_value" {
  value = nonsensitive(data.aws_ssm_parameter.dc2_amzn2_ami.value)
}

output "dc1_ami_value" {
  value = nonsensitive(data.aws_ssm_parameter.dc1_amzn2_ami.value)
}

# TODO

resource "aws_launch_template" "dc2_eks_instance" {
  provider = aws.dc2
  name     = "${var.name}-dc2-eks-instance"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 100
      volume_type = "gp2"
    }
  }


  image_id = data.aws_ssm_parameter.dc2_amzn2_ami.value
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
/etc/eks/bootstrap.sh ${aws_eks_cluster.dc2_eks.id}
--==MYBOUNDARY==--\
  EOF
  )

  # However, if you want to use your own custom security groups, 
  # you have to include both the custom security group that you want AND 
  # the default EKS Cluster’s security group in order to allow the necessary network connections.
  vpc_security_group_ids = [
    aws_eks_cluster.dc2_eks.vpc_config[0].cluster_security_group_id,
    aws_security_group.dc1_to_dc2_traffic.id,
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                                  = "${var.name}-dc2-eks-instance"
      "kubernetes.io/cluster/${aws_eks_cluster.dc2_eks.id}" = "owned"
    }
  }
}

output "aws_eks_cluster_dc2_eks_vpc_config" {
  value = aws_eks_cluster.dc2_eks.vpc_config
}