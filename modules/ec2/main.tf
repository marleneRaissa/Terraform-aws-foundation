resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip
  user_data                   = var.user_data
  tags = merge(
    { Name = var.instance_name },
    var.tags
  )

# Terraform essaie plutôt de faire : créer la nouvelle instance puis supprimer l’ancienne si jamais on veut apporter des modif à une instance
  lifecycle {
    create_before_destroy = true
  }
}