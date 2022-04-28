terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//?ref=v3.2.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  name = "test-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["${include.inputs.aws_region}a", "${include.inputs.aws_region}b", "${include.inputs.aws_region}c"]
  private_subnets  = ["10.0.1.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway           = false
  create_database_subnet_group = true
  single_nat_gateway           = false
  enable_vpn_gateway           = false

  tags = {
    Terraform   = "true"
    Environment = include.inputs.env
    Owner       = include.inputs.account_name
  }
}
