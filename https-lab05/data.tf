# fetch remote state from S3 Bucket (lab04)
data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = "terraform-state-bucket-s3-project01"
    key    = "lab04/dev/terraform.tfstate"
    region = "eu-north-1"
  }
}
