locals {
  nb_of_public_subnets  = 2
  nb_of_private_subnets = 2
  az_list               = var.availability_zones
  derived_subnet_cidrs = [
    for i in range(local.nb_of_public_subnets + local.nb_of_private_subnets) :
    cidrsubnet(var.vpc_cidr, 8, i)
  ]

  /*
  What “derived subnet CIDRs” actually means?

  You start with one big network

  From that one block, you must cut smaller, non-overlapping blocks:
  public subnet A, public subnet B, private subnet A, private subnet B
  These smaller blocks are derived from the VPC CIDR.

  You are not inventing new IP ranges.
  You are mathematically splitting the VPC CIDR.

  Terraform forbids guessing CIDRs. Terraform gives you: cidrsubnet()

Parameter 2 — newbits
  How many bits you add to the mask.

    Example vpc : CIDR IPv4 172.31.0.0/16 ---> masque reseau 16 bits

            Avant emprunt (VPC /16) : 32 bits au total
            [ 16 bits réseau ][ 16 bits hôtes ]
                                    ↑
                                16 bits pour les hôtes
                                = 2^16 = 65,536 machines possibles

    Reste 32 - 16 bit reseaux = 16 bit pour la partie hôte
    
    on veut un subnets /24 : Quand on veut créer des sous-réseaux, on va "emprunter" des bits de la partie hôte pour créer des sous-parties réseau
    
    1. Combien de bits empruntés ? : 24 - 16 = 8 bits : Ces 8 bits sont "empruntés" de la partie hôte pour devenir partie réseau du subnet

            Après emprunt (subnet /24) : 172.31.0.0/24
            [ 16 bits réseau ][ 8 bits empruntés ][ 8 bits hôtes ]
                                    ↑                    ↑
                                Bits pris aux hôtes   Bits restants
                                pour créer des        pour les machines
                                sous-réseaux          dans chaque subnet

    2. Visualisation des 8 bits empruntés
      
            172.31.50.100
                │   │  │
                │   │  └─ hôte → 100 Appartement
                │   └──── bits empruntés → 50 Étage Il détermine quel subnet !
                └───────── réseau VPC → 172.31 Immeuble

    3. Combien de sous-réseaux possibles ? 2^8 = 256 sous-réseaux différents (Chaque combinaison des 8 bits donne un subnet différent)
        de 172.31.0.0/24 à 172.31.255.0/24

        Sans sous-réseaux (juste le VPC) :
        172.31.0.0 à 172.31.255.255 (65,536 adresses)

        Avec sous-réseaux /24 (on emprunte 8 bits) :
        Subnet 1 : 172.31.0.0   à 172.31.0.255   (256 adresses)
        Subnet 2 : 172.31.1.0   à 172.31.1.255   (256 adresses)
        Subnet 3 : 172.31.2.0   à 172.31.2.255   (256 adresses)
        ...
        Subnet 256 : 172.31.255.0 à 172.31.255.255 (256 adresses)


Parameter 3 — netnum
  Which subnet index you want.
  Think:
  Subnet 0 → cidrsubnet(VPC, 8, 0)
  Subnet 1 → cidrsubnet(VPC, 8, 1)
  Subnet 2 → cidrsubnet(VPC, 8, 2)
  Subnet 3 → cidrsubnet(VPC, 8, 3)
  you can say: first 2 → public, next 2 → private
  Each netnum gives a different subnet, non-overlapping.

  */

}