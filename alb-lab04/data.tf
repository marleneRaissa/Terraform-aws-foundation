# fetch remote state from S3 Bucket (lab02)
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terraform-state-bucket-s3-project01"
    key    = "lab02/vpc/terraform.tfstate"
    region = "eu-north-1"
  }
}

# fetch remote state from S3 Bucket (lab03)
data "terraform_remote_state" "compute" {
  backend = "s3"

  config = {
    bucket = "terraform-state-bucket-s3-project01"
    key    = "lab03/bastion-aws-ssm/terraform.tfstate"
    region = "eu-north-1"
  }
}