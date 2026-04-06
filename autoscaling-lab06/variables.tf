variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/deployer-key.pub"
}

variable "lt_key_name" {
  description = "Key pair name for SSH (generated from the AWS console)"
  type        = string
  default     = "launch-template-key"
}

variable "extra_tags" {
  description = "Tags"
  type        = map(string)

  // Default values are defined here for learning; prod values belong in terraform.tfvars
  default = {
    Name    = "private_app_ec2_asg"
    Env     = "dev"
    Project = "lab06-autoscaling"
  }
}