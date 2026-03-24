# Bastion Host = A single EC2 instance that is allowed to be accessed from
# the internet, whose only job is to let you safely access private machines.


########### SSH from my laptop → Bastion EC2 (publique) → Private EC2  ###########

# -------------------------------------------- Bastion --------------------------------------------- #
# Crée un Security Group spécifique pour le Bastion Host. Ce SG sera attaché à l'instance ec2 Bastion
# Il protège l’instance Bastion EC2.
# Dans AWS, un Security Group ne fait pas tout seul entrer du trafic. Il faut ensuite lui ajouter des règles.
# ------------------------------------------------------------------------------------------------- #
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "allow SSH only from my IP and all outbound traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name    = "bastion-sg"
    Env     = "dev"
    Project = "lab03-secure-workloads"
  }
}

# ------------------------------------------------------------- Bastion ---------------------------------------------------------- #
# Autorise la connexion SSH (port 22) vers le Bastion
# Source : UNIQUEMENT votre adresse IP (var.admin_ip)
# Pourquoi : Seule vous pouvez vous connecter au Bastion : Votre ordinateur (IP: 86.99.90.165) ──SSH──→ Bastion Host (dans public subnet)
# Sans cette règle :le bastion existe, mais personne ne peut s’y connecter en SSH
# ------------------------------------------------------------------------------------------------------------------------------- #
resource "aws_vpc_security_group_ingress_rule" "ssh_from_admin_ip" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = var.admin_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# ------------------------------------------------------------- Bastion ---------------------------------------------------------- #
# C’est la règle qui autorise le bastion à se connecter à l’EC2 privée en SSH.
# toute machine ayant le SG bastion_sg peut parler en SSH à la machine ayant private_ec2_sg : SG-to-SG (machines)
# NB : Ce n'est pas une IP qui est autorisée, mais un Security Group
# ------------------------------------------------------------------------------------------------------------------------------- #
resource "aws_vpc_security_group_ingress_rule" "ssh_from_bastion" {
  security_group_id            = aws_security_group.private_ec2_sg.id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}


# ------------------------------------------------------------- Bastion ---------------------------------------------------------- #
# Autorise tout le trafic sortant du Bastion vers Internet
# Destination : Toutes les adresses IP (0.0.0.0/0)
# Pourquoi ? Le Bastion doit pouvoir : Télécharger des mises à jour, Résoudre des noms DNS, Se connecter aux instances privées
# ------------------------------------------------------------------------------------------------------------------------------- #
resource "aws_vpc_security_group_egress_rule" "bastion_all_out" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# ------------------------------------------------------------- Bastion ---------------------------------------------------------- #
# Bastion EC2 - Public subnet : Crée une instance EC2 appelé bastion_ec2 dans le subnet public
# ------------------------------------------------------------------------------------------------------------------------------- #
resource "aws_instance" "bastion_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]   # place bastion dans le subnet_public0
  associate_public_ip_address = true                                                           # bastion_ec2 reçoit une IP publique, indispensable pour s’y connecter depuis Internet
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]                             # Attache le SG bastion_ec2
  key_name                    = aws_key_pair.bastion_key.key_name    

  tags = {
    Name    = "bastion-ec2-public"
    Env     = "dev"
    Project = "lab03-secure-workloads"
  }
}

# ------------------------------------------------------------- Bastion ---------------------------------------------------------- #
# App EC2  - Private subnet : Crée une instance EC2 dans le subnet privé
# Elle héberge une application ou un service interne
# ------------------------------------------------------------------------------------------------------------------------------- #
resource "aws_instance" "app_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]   # recupération du subnet privé via le fichier de sauvegarde dans s3
  associate_public_ip_address = false                                                           # Pas d'IP publique
  vpc_security_group_ids      = [aws_security_group.private_ec2_sg.id]                          # Attache l'instance au SG du reseau privé
  key_name = aws_key_pair.bastion_key.key_name

  tags = {
    Name    = "app-ec2-private"
    Env     = "dev"
    Project = "lab03-secure-workloads"
  }
}


# ------------------------------------------------------------- Ressource commune Bastion et AWS SSM ---------------------------------------------------------- #
# App EC2  - Private subnet : Crée une instance EC2 dans le subnet privé
# Il protège la machine privée.
# ------------------------------------------------------------------------------------------------------------------------------- #
resource "aws_security_group" "private_ec2_sg" {
  name   = "private_ec2_sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = {
    Name    = "private_ec2_sg"
    Env     = "dev"
    Project = "lab03-secure-workloads"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "marlene-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

/*
# ------------------------------ Admin -> Accès via SSM Session Manager -> Private EC2 / Instances ASG  ------------------------------------ #

# ------------------------------------------------------------- AWS SSM ---------------------------------------------------------- #
# App EC2  - Private subnet : Crée une instance EC2 dans le subnet privé
# Dans l’ancienne approche bastion, Il fonctionne avec : une règle entrante SSH depuis le bastion, une règle sortante vers l’extérieur
# ici la machine privée peut émettre du trafic sortant partout, AUCUN traffic entrant
# ------------------------------------------------------------------------------------------------------------------------------- #
resource "aws_vpc_security_group_egress_rule" "private_ec2_all_out" {
  security_group_id = aws_security_group.private_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
*/