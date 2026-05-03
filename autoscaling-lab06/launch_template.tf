# Provides an EC2 launch template resource. Can be used to create instances or auto scaling groups.
resource "aws_launch_template" "ec2_template" {

  # Required pieces : *AMI, *Instance type, *Security Group, *Key pair, *User data, IAM  
  name                   = "lab06-lt"
  image_id               = data.aws_ami.amazon_linux.image_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.terraform_remote_state.compute.outputs.app_ec2_sg_id] # Your private EC2 SG (NOT bastion, NOT ALB)
  key_name               = var.lt_key_name

  // aws_instance → accepts plain text user_data
  // aws_launch_template → REQUIRES Base64-encoded user data
  user_data = base64encode(
    file("${path.module}/user_data.sh")
  )

  // so the SSH can be done through SSM Session Manager
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  }

  tags = {
    Name    = "lab06-lt"
    Env     = "dev"
    Project = "lab06-autoscaling"
  }

}