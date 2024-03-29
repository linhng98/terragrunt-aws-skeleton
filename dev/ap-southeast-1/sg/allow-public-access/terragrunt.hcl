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
  name        = "terraform-allow-public-access-sg"
  description = "allow public access"
  vpc_id      = dependency.vpc.outputs.vpc_id

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}
