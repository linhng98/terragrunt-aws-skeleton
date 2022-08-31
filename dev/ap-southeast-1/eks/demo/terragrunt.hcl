terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//?ref=v18.23.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "allow_ssh_sg" {
  config_path = "../../sg/allow-ssh"
}

locals {
  cluster_name = "my-cluster"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${include.inputs.aws_region}"
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.this[0].id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this[0].id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
EOF
}

inputs = {
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnet_ids      = dependency.vpc.outputs.public_subnets
  vpc_id          = dependency.vpc.outputs.vpc_id
  manage_aws_auth = true

  eks_managed_node_group_defaults = {
    key_name = "linhnv"
    vpc_security_group_ids = [
      "${dependency.allow_ssh_sg.outputs.security_group_id}",
    ]
  }

  eks_managed_node_groups = {
    node_group_1 = {
      min_size     = 3
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = include.inputs.env
    Owner       = include.inputs.account_name
  }
}
