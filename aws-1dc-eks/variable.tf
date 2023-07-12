
# Prefix naming of resources in AWS console
variable "name" {
  default = "taku-1dc-eks"
}

# CIDR Block of VPC in DC1. Must be a subset of CIDR in dc1_zones
variable "dc1_vpc_cidr_block" {
  default = "172.16.0.0/16"
}

# Name of the SSH key to be setup in DC1 instances.
# This must be uploaded beforehand so it can be referenced as a string
variable "dc1_ssh_keyname" {
  default = "ap_northeast_1_taku"
}

# Where to deploy jumphost for SSH access
variable "jumphost_az" {
  default = "ap-northeast-1a"
}

# Region definition of DC1
variable "dc1_region" {
  default = "ap-northeast-1"
}

# DC1 zones configuration. 
# Add/subtract any keys in private_subnets to change the number of zones
variable "dc1_zones" {
  type = map(any)
  default = {
    private_subnets = {
      private-1a = {
        name = "private-1a"
        cidr = "172.16.10.0/24"
        az   = "ap-northeast-1a"
      },
      private-1c = {
        name = "private-1c"
        cidr = "172.16.11.0/24"
        az   = "ap-northeast-1c"
      },
      private-1d = {
        name = "private-1d"
        cidr = "172.16.12.0/24"
        az   = "ap-northeast-1d"
      }
    }
    public_subnets = {
      public-1a = {
        name = "public-1a"
        cidr = "172.16.13.0/24"
        az   = "ap-northeast-1a"
      },
      public-1c = {
        name = "public-1c"
        cidr = "172.16.14.0/24"
        az   = "ap-northeast-1c"
      },
      public-1d = {
        name = "public-1d"
        cidr = "172.16.15.0/24"
        az   = "ap-northeast-1d"
      }
    }
  }
}


# You can specify versions of EKS addons here.
# To get the right versions, run
# aws eks describe-addon-versions > addons.json
variable "eks_addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.27.1-eksbuild.1"
    },
    {
      name    = "vpc-cni"
      version = "v1.12.6-eksbuild.2"
    },
    {
      name    = "coredns"
      version = "v1.10.1-eksbuild.1"
    }
  ]
}