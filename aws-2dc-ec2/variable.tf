
# Prefix naming of resources in AWS console
variable "name" {
  default = "taku-2dc-ec2"
}

# CIDR Block of Jumphost in DC1. Must not overlap with ec2_vpc_cidr_block
variable "jumphost_vpc_cidr_block" {
  default = "172.22.0.0/16"
}

# CIDR Block of VPC in DC1. Must be a subset of CIDR in dc1_zones
variable "dc1_vpc_cidr_block" {
  default = "172.16.0.0/16"
}

# CIDR Block of VPC in DC2. Must be a subset of CIDR in dc2_zones
variable "dc2_vpc_cidr_block" {
  default = "172.17.0.0/16"
}

# Name of the SSH key to be setup in DC1 instances.
# This must be uploaded beforehand in DC1 so it can be referenced as a string
variable "dc1_ssh_keyname" {
  default = "ap_northeast_1_taku"
}

# Name of the SSH key to be setup in DC2 instances
# This must be uploaded beforehand in DC2 so it can be referenced as a string
variable "dc2_ssh_keyname" {
  default = "ap_northeast_3_taku"
}

# Where to deploy jumphost for SSH access
variable "jumphost_az" {
  default = "ap-northeast-1a"
}

# Region definition of DC1
variable "dc1_region" {
  default = "ap-northeast-1"
}

# Region definition of DC2
variable "dc2_region" {
  default = "ap-northeast-3"
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

# DC2 zones configuration. 
# Add/subtract any keys in private_subnets to change the number of zones
variable "dc2_zones" {
  type = map(any)
  default = {
    private_subnets = {
      private-3a = {
        name = "private-3a"
        cidr = "172.17.20.0/24"
        az   = "ap-northeast-3a"
      },
      private-3b = {
        name = "private-3b"
        cidr = "172.17.21.0/24"
        az   = "ap-northeast-3b"
      },
      private-3c = {
        name = "private-3c"
        cidr = "172.17.22.0/24"
        az   = "ap-northeast-3c"
      }
    }
    public_subnets = {
      public-3a = {
        name = "public-3a"
        cidr = "172.17.23.0/24"
        az   = "ap-northeast-3a"
      },
      public-3b = {
        name = "public-3b"
        cidr = "172.17.24.0/24"
        az   = "ap-northeast-3b"
      },
      public-3c = {
        name = "public-3c"
        cidr = "172.17.25.0/24"
        az   = "ap-northeast-3c"
      }
    }
  }
}