# Provides a security group resource.
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "ALB Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name    = "alb_sg"
    Env     = "dev"
    Project = "lab04-alb"
  }
}

# igress rules

// Internet → ALB (80)
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

// Internet → ALB (443)
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

// ALB SG → Private EC2 SG (80)
resource "aws_vpc_security_group_ingress_rule" "from_alb_sg" {
  security_group_id            = data.terraform_remote_state.compute.outputs.app_ec2_sg_id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# application load balancer
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "lab04-alb-tf"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnet_ids   // Place le load balancer dans les subnets publics du VPC
  tags = {
    Name    = "lab04-alb-tf"
    Env     = "dev"
    Project = "lab04-alb"
  }
}

