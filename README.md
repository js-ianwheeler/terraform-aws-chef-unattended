# terraform-aws-chef-unattended
Use Terraform to build an EC2 instance with an unattended install of the Chef Client

This is a proof-of-concept for an unattended install of the Chef Client on an AWS EC2 instance. It is intended to be used in a network environment that does not allow SSH access to AWS public IP addresses.
Terraform creates the EC2 instance specifying a USER_DATA value that is used to install the Chef Client.

Edit variables.tf to configure.

Further documentation to follow.
