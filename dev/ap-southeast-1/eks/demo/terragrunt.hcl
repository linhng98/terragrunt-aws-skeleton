terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//?ref=v17.19.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc"
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
  cluster_version = "1.18"
  subnets         = dependency.vpc.outputs.public_subnets
  vpc_id          = dependency.vpc.outputs.vpc_id
  manage_aws_auth = true

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3.large"
      asg_desired_capacity = 1
      spot_price           = "0.1"
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t3.large"
      asg_desired_capacity = 1
      spot_price           = "0.1"
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes  = ["AZRebalance"]
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = include.inputs.env
    Owner       = include.inputs.account_name
  }
}