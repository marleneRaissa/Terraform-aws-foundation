terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-project01"
    key          = "lab02/vpc/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}