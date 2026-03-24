# fetch AMI for Amazon Linux
data "aws_ami" "amazon_linux" {
  most_recent = true
  name_regex  = "al2023-ami-"
  owners      = ["amazon"]
}

# fetch remote state from S3 Bucket
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terraform-state-bucket-project01"
    key    = "lab02/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}