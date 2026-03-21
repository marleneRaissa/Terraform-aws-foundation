terraform {
  backend "s3" {
    bucket       = "terraform-state-marlene-12345"
    key          = "project01/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}