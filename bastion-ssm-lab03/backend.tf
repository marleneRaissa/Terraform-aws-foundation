terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-s3-project01"
    key          = "lab03/bastion-aws-ssm/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}