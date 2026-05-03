# fetch remote state from S3 Bucket (lab03)
data "terraform_remote_state" "compute" {
  backend = "s3"

  config = {
    bucket = "terraform-state-bucket-s3-project01"
    key    = "lab06/autoscaling/terraform.tfstate"
    region = "eu-north-1"
  }
}