
# AWS 2DC EC2

## Features

A basic setup consisting

- 2 AWS region data centers
- Each region contains a VPC with private subnets that span across 3 availability zones
- EC2 instances are launched within each subnet
- A jumphost VPC with an EC2 is instantiated for accessibility
- VPC Peering with bidirectional access between the two regions VPC
- An unidirectional access from jumphost to other VPCs

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