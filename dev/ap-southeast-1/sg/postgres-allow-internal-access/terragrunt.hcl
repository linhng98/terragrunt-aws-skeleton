terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//?ref=v4.3.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  name        = "terraform-postgres-allow-internal-access-sg"
  description = "allow internal service access"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["postgresql-tcp"]
}