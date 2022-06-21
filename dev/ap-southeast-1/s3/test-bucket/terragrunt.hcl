terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.3.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  bucket = "linhnv-test-bucket"
  acl    = "private"

  versioning = {
    enabled = true
  }
}