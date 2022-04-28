terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git//?ref=v3.1.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "allow_public_access_sg" {
  config_path = "../../sg/allow-public-access"
}

dependency "allow_ssh_sg" {
  config_path = "../../sg/allow-ssh"
}

inputs = {
  name                        = "wireguard-gw"
  ami                         = "ami-0d058fe428540cd89"
  instance_type               = "t2.micro"
  monitoring                  = true
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${dependency.allow_public_access_sg.outputs.security_group_id}",
    "${dependency.allow_ssh_sg.outputs.security_group_id}",
  ]
  subnet_id = dependency.vpc.outputs.public_subnets[0]
  key_name  = "linhnv"

  tags = {
    Terraform   = "true"
    Environment = include.inputs.env
    Owner       = include.inputs.account_name
  }
}
