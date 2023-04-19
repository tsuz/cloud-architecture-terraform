# AWS 2DC

Two data center setup in AWS

## Setup

- Set the variables in the `variable.tf`

| variable | description |
|--|--|
| name | name prefix of resources created via Terraform |
| dc1_vpc_cidr_block | cidr block for DC1 |
| dc2_vpc_cidr_block | cidr block for DC2. The two should not overlap |
| dc1_ssh_keyname |  SSH key name to install on the hosts in DC1. These must exist in the region. |
| dc2_ssh_keyname |  SSH key name to install on the hosts in DC2. These must exist in the region. |
| dc1_region | Region name for DC1 |
| dc2_region | Region name for DC2 |
| dc1_zones | Region zones to use for DC1 |
| dc2_zones | Region zones to use for DC2 |

Build resources

```
terraform apply
```


## Notes

- The VMs have a very open access protocol. This needs to be restricted for a real world use.
