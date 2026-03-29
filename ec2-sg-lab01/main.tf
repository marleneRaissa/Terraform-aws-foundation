module "security_group" {
  source = "./modules/security_group"

  security_group_name        = "${var.environment}-sg-lab01"
  security_group_description = "Security group created with Terraform"
  vpc_id                     = data.aws_vpc.fetch_vpc.id

  inbound_rules_ipv4 = {
    ssh = {
      cidr_ipv4   = "86.99.90.165/32" // Autorise les connexions SSH UNIQUEMENT votre IP (Très restreint, seulement cette @ip peut se connecter)
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      description = "SSH from my IP address"
    }
    http = {
      cidr_ipv4   = "0.0.0.0/0" // Autorise le trafic HTTP (Permet à n'importe qui "adresses IPv4" dans le monde d'accéder à votre site web)
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      description = "HTTP from 0.0.0.0/0"
    }
  }

  outbound_rules_ipv4 = {
    all = {
      cidr_ipv4   = "0.0.0.0/0" // Votre instance a accès a tout internet 
      protocol    = "-1"       //  signifie "tous les protocoles" (TCP, UDP, ICMP, etc.)
      from_port   = -1        // signifie "tous les ports"
      to_port     = -1
      description = "HTTP from 0.0.0.0/0 (outbound)"

    }
  }

  tags = {
    Name = "lab01"
    Env  = var.environment
    Team = "SD"
  }

}


module "ec2" {
  source = "./modules/ec2"

  // INPUT
  instance_name          = "${var.environment}-ec2-lab01"
  instance_type          = var.instance_type
  subnet_id              = local.first_subnet_id
  vpc_security_group_ids = [module.security_group.vpc_security_group_id]
  key_name               = var.ssh_key_name
  associate_public_ip    = false
  user_data              = file("./modules/ec2/user_data.sh")

  // ${path.module} - This is best practice
  // Ensures the file is found relative to the module
  // Works no matter where the module is called from

  tags = {
    Env  = var.environment
    Team = "SD"
  }

}