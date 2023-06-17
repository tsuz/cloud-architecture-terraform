terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  alias  = "dc1"
  region = var.dc1_region
}

provider "aws" {
  alias  = "dc2"
  region = var.dc2_region
}

