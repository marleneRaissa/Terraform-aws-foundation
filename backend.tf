terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-project01"
    key          = "project01/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    dynamodb_table = "terraform-locks"
  }
}