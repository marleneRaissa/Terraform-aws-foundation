
# Terraform Ressources (vpc, internet_gateway, route_table, route_table_association, eip, nat_gateway)

## Ce que tu vas apprendre
- Provisioning d’un VPC AWS complet avec Terraform
- Création de subnets publics et privés
- Mise en place d’une Internet Gateway et d’une NAT Gateway
- Configuration des route tables et associations de subnets
- Sortie Internet sécurisée pour les ressources privées
- Architecture réseau prête pour héberger des workloads applicatifs


### Les ressources utilisées
- 1 VPC
- des subnets publics
- des subnets privés
- 1 Internet Gateway
- 1 NAT Gateway
- 1 table de routage publique
- 1 table de routage privée
- 1 Elastic IP
- et les associations qui relient chaque subnet à la bonne table


## Ce que cette architecture montre

1. Séparation claire entre public et privé
    - des subnets publics
    - des subnets privés

2. Mise en place d’un VPC structuré (cfère les ressources citées plus haut)

3. Compréhension du rôle des route tables
   Cette architecture permet de bien comprendre qu’un subnet devient :
    - public s’il pointe vers l’Internet Gateway
    - privé s’il pointe vers la NAT Gateway

4. Sortie Internet sécurisée pour les subnets privés
    - Les ressources privées ne sortent pas directement sur Internet.
    - Elles passent par une NAT Gateway.

5. Hébergement correct du NAT Gateway
    - un NAT doit être dans un subnet public pour permettre aux subnets privés de sortir vers Internet

6. Répartition en plusieurs subnets
    - 2 publics
    - 2 privés
   Cela montre une logique de : séparation, évolutivité, préparation à une architecture multi-AZ

7. Utilisation des count pour automatiser la création
    - Ton code ne crée pas les subnets un par un à la main.
    - Il utilise count.
    C’est intéressant car cela montre :
        une approche plus propre
        une logique plus scalable
        moins de duplication dans le code

8. Utilisation de variables et locals
   Cela montre que ton code est :
        paramétrable
        réutilisable
        plus professionnel qu’un code full hardcodé

9. Tagging des ressources
   C’est un bon point à mettre en avant, car dans un vrai environnement cloud les tags servent à :
        organiser
        filtrer
        suivre les coûts
        mieux administrer les ressources

10. Dépendances Terraform bien comprises
    Le code montre aussi la logique de dépendance entre ressources :
        le VPC doit exister avant les subnets
        l’IGW doit exister avant certaines routes
        le NAT dépend de l’EIP et du subnet public
        les associations de route table arrivent après
    Cela montre que tu commences à comprendre le fonctionnement réel de Terraform.

11. Bonne base pour déployer une application
    Cette architecture est une bonne fondation pour héberger ensuite :
        des EC2 applicatives
        un bastion
        un load balancer
        une base RDS
        Elastic Beanstalk
        des services backend



## Schéma de fonctionnement

```text
                                 🌍 INTERNET
                                       ▲
                                       │
                                       │ Trafic SORTANT des instances privées
                                       │ (via NAT Gateway)
                                       │
                                       │ Trafic ENTRANT vers ressources publiques
                                       │ (via IGW)
                                       │
                          ┌────────────┴────────────┐
                          │                         │
                          ▼                         ▲
              ┌──────────────────────┐    ┌──────────────────────┐
              │  Internet Gateway    │    │  Internet Gateway    │
              │ aws_internet_gateway │    │ aws_internet_gateway │
              │        .igw          │    │        .igw          │
              │                      │    │                      │
              │   TRAFIC ENTRANT     │    │   TRAFIC SORTANT     │
              │   (↓ vers VPC)       │    │   (↑ vers Internet)  │
              └──────────┬───────────┘    └──────────▲───────────┘
                         │                           │
                         │                           │
                    ┌────┴───────────────────────────┴────┐
                    │                                     │
                    │              VPC                    │
                    │       aws_vpc.main_vpc              │
                    │         cidr = var.vpc_cidr         │
                    │                                     │
                    └─────────────────────────────────────┘
                                      │
                                      │
          ┌───────────────────────────┼───────────────────────────┐
          │                           │                           │
          │                           │                           │
          ▼                           ▼                           ▼

 ┌───────────────────┐      ┌───────────────────┐      ┌───────────────────┐
 │   Public Subnet 1 │      │   Public Subnet 2 │      │   Public Subnet 3 │
 │ aws_subnet        │      │ aws_subnet        │      │ aws_subnet        │
 │ .public_subnets[0]│      │ .public_subnets[1]│      │ .public_subnets[2]│
 │ map_public_ip=yes │      │ map_public_ip=yes │      │ map_public_ip=yes │
 │                   │      │                   │      │                   │
 │ ╔═══════════════╗ │      │                   │      │                   │
 │ ║ NAT Gateway   ║ │      │                   │      │                   │
 │ ║ (hébergé ici) ║ │      │                   │      │                   │
 │ ╚═══════════════╝ │      │                   │      │                   │
 └─────────┬─────────┘      └───────────────────┘      └───────────────────┘
           │
           │ association
           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Route Table publique (rt_public)                         │
│                                                                             │
│                    ┌────────────────────────────────────┐                   │
│                    │ Route: 0.0.0.0/0 → IGW            │                    │
│                    │ (TRAFIC ENTRANT ET SORTANT)       │                    │
│                    └────────────────────────────────────┘                   │
│                                                                             │
│    Associée aux subnets publics : public_subnets[0], [1], [2]               │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ▲
                                      │
                                      │ association
                                      │
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Route Table privée (rt_private)                          │
│                                                                             │
│                    ┌────────────────────────────────────┐                   │
│                    │ Route: 0.0.0.0/0 → NAT Gateway     │                   │
│                    │ (TRAFIC SORTANT UNIQUEMENT)        │                   │
│                    └────────────────────────────────────┘                   │
│                                                                             │
│    Associée aux subnets privés private_subnets[0], [1], [2]                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ▲
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         │                            │                            │
         │                            │                            │
         ▼                            ▼                            ▼
┌────────────────────┐      ┌───────────────────┐      ┌───────────────────┐
│  Private Subnet 1  │      │  Private Subnet 2 │      │  Private Subnet 3 │
│ aws_subnet         │      │ aws_subnet        │      │ aws_subnet        │
│ .private_subnets[0]│      │.private_subnets[1]│      │.private_subnets[2]│
│ map_public_ip=no   │      │ map_public_ip=no  │      │ map_public_ip=no  │
│                    │      │                   │      │                   │
│ ┌───────────────┐  │      │ ┌───────────────┐ │      │ ┌───────────────┐ │
│ │ Application   │  │      │ │ Application   │ │      │ │ Base de       │ │
│ │ Server        │  │      │ │ Server        │ │      │ │ Données       │ │
│ └───────────────┘  │      │ └───────────────┘ │      │ └───────────────┘ │
└────────────────────┘      └───────────────────┘      └───────────────────┘
         │                            │                            │
         │                            │                            │
         └────────────────────────────┼────────────────────────────┘
                                      │
                                      │ Trafic SORTANT
                                      │ (mises à jour, API externes)
                                      ▼
                              ┌───────────────────┐
                              │    NAT Gateway    │
                              │  aws_nat_gateway  │
                              │                   │
                              │  Traduit IP privée│
                              │  → IP publique    │
                              └─────────┬─────────┘
                                        │
                                        │ utilise
                                        ▼
                              ┌───────────────────┐
                              │    Elastic IP     │
                              │   aws_eip.eip     │ ← Crée une adresse IP publique statique attaché à NAT Gateway
                              │   (IP publique)   │
                              └─────────┬─────────┘
                                        │
                                        │ Trafic SORTANT
                                        │ vers Internet
                                        ▼
                                    🌍 INTERNET
```

#### Exemple de trafic

1. La DB veut aller sur : https://aws.amazon.com
   Adresse IP : 52.94.236.248

2. Elle regarde sa table de routage (rt_private) :
   Destination = 52.94.236.248
   Est-ce que 52.94.236.248 correspond à 0.0.0.0/0 ? OUI

3. Route trouvée : gateway_id = nat-12345678

4. La DB envoie le paquet à la NAT Gateway

5. La NAT Gateway reçoit le paquet, change l'IP source
   (de l'IP privée de la DB vers son IP publique)

6. Le paquet sort sur Internet

7. La réponse revient à la NAT Gateway

8. La NAT Gateway retransmet la réponse à la DB

9. La DB a reçu sa mise à jour !


### Checklist à vérifier

```text
|-----------------------------------|---------------------------------------------------|---------|
| Point                             | Code Terraform                                    | Statut  |
|-----------------------------------|---------------------------------------------------|---------|

| IGW attaché au VPC                | `vpc_id = aws_vpc.main_vpc.id`                    | ✅      |

| Subnets publics avec IP publique  | `map_public_ip_on_launch = true`                  | ✅      |

| Subnets privés sans IP publique   | `map_public_ip_on_launch = false`                 | ✅      |

| Route table publique → IGW        | `gateway_id = aws_internet_gateway.igw.id`        | ✅      |

| Route table privée → NAT          | `gateway_id = aws_nat_gateway.nat.id`             | ✅      |

| Association public subnets        | `route_table_id = aws_route_table.rt_public.id`   | ✅      |

| Association private subnets       | `route_table_id = aws_route_table.rt_private.id`  | ✅      |

| NAT dans public_subnet[0]         | `subnet_id = aws_subnet.public_subnets[0].id`     | ✅      |

| EIP attaché à NAT                 | `allocation_id = aws_eip.eip.id`                  | ✅      |

| Dépendance NAT → IGW              | `depends_on = [aws_internet_gateway.igw]`         | ✅      |
|-----------------------------------|---------------------------------------------------|---------|
```