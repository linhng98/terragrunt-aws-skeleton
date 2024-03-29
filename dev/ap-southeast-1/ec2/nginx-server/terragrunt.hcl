terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git//?ref=v4.1.4"
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

dependency "allow_http_sg" {
  config_path = "../../sg/allow-http"
}

inputs = {
  ami           = "ami-02ee763250491e04a"
  instance_type = "t2.medium"

  create_spot_instance = false
  spot_price           = "0.60"
  spot_type            = "persistent"

  monitoring                  = true
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${dependency.allow_public_access_sg.outputs.security_group_id}",
    "${dependency.allow_ssh_sg.outputs.security_group_id}",
    "${dependency.allow_http_sg.outputs.security_group_id}",
  ]
  subnet_id                   = dependency.vpc.outputs.public_subnets[0]
  key_name                    = "linhnv"
  user_data                   = <<-EOF
    #!/bin/bash
    apt install -y nginx
  EOF
  user_data_replace_on_change = true
}
