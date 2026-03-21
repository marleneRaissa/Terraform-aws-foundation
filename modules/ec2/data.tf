# récupérer dynamiquement des informations sur une AMI (Amazon Machine Image) depuis AWS
data "aws_ami" "amazon_linux" {
  most_recent = true
  name_regex  = "al2023-ami-"
  owners      = ["amazon"]

  // ami name : al2023-ami-2023.9.20251208.0-kernel-6.1-x86_64
  // ami id : ami-068c0051b15cdb816 
}

# Mauvaise pratique - ID codé en dur
#resource "aws_instance" "example" {
#  ami = "ami-068c0051b15cdb816"  # Cet ID n'est valide que dans une région
#}
