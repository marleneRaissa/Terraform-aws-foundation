terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-project01"
    key          = "lab03/bastion-aws-ssm/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}