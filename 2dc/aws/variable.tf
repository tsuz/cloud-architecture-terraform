variable "name" {
  default = "taku-2dc"
}

variable "dc1_vpc_cidr_block" {
  default = "172.16.0.0/16"
}

variable "dc2_vpc_cidr_block" {
  default = "172.17.0.0/16"
}

variable "dc1_ssh_keyname" {
  default = "ap_northeast_1_taku"
}

variable "dc2_ssh_keyname" {
  default = "ap_northeast_3_taku"
}

variable "dc1_region" {
  default = "ap-northeast-1"
}

variable "dc2_region" {
  default = "ap-northeast-3"
}

variable "dc1_zones" {
  type = map(any)
  default = {
    public_subnets = {
      public-1a = {
        name = "public-1a"
        cidr = "172.16.10.0/24"
        az   = "ap-northeast-1a"
      },
      public-1c = {
        name = "public-1c"
        cidr = "172.16.11.0/24"
        az   = "ap-northeast-1c"
      },
      public-1d = {
        name = "public-1d"
        cidr = "172.16.12.0/24"
        az   = "ap-northeast-1d"
      }
    }
  }
}

variable "dc2_zones" {
  type = map(any)
  default = {
    public_subnets = {
      public-1a = {
        name = "public-3a"
        cidr = "172.17.20.0/24"
        az   = "ap-northeast-3a"
      },
      public-1c = {
        name = "public-3b"
        cidr = "172.17.21.0/24"
        az   = "ap-northeast-3b"
      },
      public-1d = {
        name = "public-3c"
        cidr = "172.17.22.0/24"
        az   = "ap-northeast-3c"
      }
    }
  }
}