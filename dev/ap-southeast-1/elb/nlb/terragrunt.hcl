terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v7.0.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}