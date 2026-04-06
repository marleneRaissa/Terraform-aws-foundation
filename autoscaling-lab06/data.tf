# fetch AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  name_regex  = "al2023-ami-"
  owners      = ["amazon"]

  // ami name : al2023-ami-2023.9.20251208.0-kernel-6.1-x86_64
  // ami id : ami-068c0051b15cdb816 

}

# Data Source for Assume Role Policy
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

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
    key    = "lab03/dev/terraform.tfstate"
    region = "eu-north-1"
  }
}

# fetch remote state from S3 Bucket (lab04)
data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = "terraform-state-bucket-s3-project01"
    key    = "lab04/dev/terraform.tfstate"
    region = "eu-north-1"
  }
}
