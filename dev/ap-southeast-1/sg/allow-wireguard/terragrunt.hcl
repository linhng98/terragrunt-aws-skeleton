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
  name        = "terraform-allow-wireguard-sg"
  description = "allow wireguard range port"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 51821
      to_port     = 51831
      protocol    = "udp"
      description = "wireguard ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}