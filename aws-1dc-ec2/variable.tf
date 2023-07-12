
# Prefix naming of resources in AWS console
variable "name" {
  default = "taku-1dc-3az"
}

# CIDR Block of VPC in DC1. Must not overlap with jumphost_vpc_cidr_block
variable "ec2_vpc_cidr_block" {
  default = "172.16.0.0/16"
}

# CIDR Block of Jumphost in DC1. Must not overlap with ec2_vpc_cidr_block
variable "jumphost_vpc_cidr_block" {
  default = "172.22.0.0/16"
}

# Name of the SSH key to be setup in DC1 instances.
# This must be uploaded beforehand so it can be referenced as a string
variable "dc1_ssh_keyname" {
  default = "my_ssh_key_name"
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
        # private IPs
        cidr = "172.16.10.0/24"
        az   = "ap-northeast-1a"
      },
      private-1c = {
        name = "private-1c"
        # private IPs
        cidr = "172.16.11.0/24"
        az   = "ap-northeast-1c"
      },
      private-1d = {
        name = "private-1d"
        # private IPs
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
