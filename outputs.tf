output "environment" {
  value = var.environment
}
output "ec2_private_ip" {
  value = module.ec2.private_ip  # on recupère les outputs du module ec2
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "list_subnet" {
  value = data.aws_subnets.list_subnet.ids
}

output "list_security_group" {  # on recupère les variables de la ressource data (l'id du security_group par defaut)
  value = data.aws_security_group.default_sg.arn
}