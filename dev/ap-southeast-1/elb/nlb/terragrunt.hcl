terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v7.0.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "allow_http_sg" {
  config_path = "../../sg/allow-http"
}

dependency "instance" {
  config_path = "../../ec2/nginx-server"
}

inputs = {
  name               = "nlb-ec2"
  load_balancer_type = "network"

  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets
  #security_groups    = ["${dependency.allow_http_sg.outputs.security_group_id}"]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = dependency.instance.outputs.id
          port      = 80
        }
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]
}
