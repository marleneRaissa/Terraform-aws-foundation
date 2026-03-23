module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  environment        = "dev"
  project_name       = "lab02-full-vpc"
  availability_zone = ["eu-north-1a", "eu-north-1b"] // do not mix Regions (us-east-1), and AZ (eu-north-1a)
}