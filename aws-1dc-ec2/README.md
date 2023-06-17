
# AWS 1DC 3AZ EC2

## Features

A basic setup consisting

- 1 region data center within Amazon Web Services
- A VPC with private subnets that span across 3 availability zones
- EC2 instances within each private subnet
- A jumphost VPC that is accessible externally
- VPC Peering between jumphost VPC and the VPC that consists of EC2s.

## Architecture

![architecture](img/architecture.png)

## Prerequisites

1. [Install terraform][1] on your local machine.
2. [Set AWS environmental variables][2].

## How to Run

1. Edit `variable.tf` to specify naming, keys, regions, zones, and cidr blocks.
2. Run `terraform apply` to execute

## Tear down

1. Run `terraform destroy`

[1]: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
[2]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables