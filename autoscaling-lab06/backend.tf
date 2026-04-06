terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-s3-project01"
    key          = "lab06/alb/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}