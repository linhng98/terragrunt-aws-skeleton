terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//?ref=v4.9.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  name        = "terraform-allow-http-sg"
  description = "allow http and https"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
}