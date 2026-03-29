# secure-workloads

## 🎯 Objectif

Ce laboratoire démontre l'évolution d'une architecture sécurisée AWS, passant d'une approche traditionnelle avec Bastion Host à une approche moderne utilisant AWS Systems Manager (SSM) Session Manager. Ce lab parle de la sécurisation de l’accès à des EC2 privées.

Avant : aws_instance.app_ec2
Maintenant : Auto Scaling Group

## 🏗️ ANCIENNE ARCHITECTURE (Avec Bastion Host) 
Ancienne méthode :
    1 EC2 Bastion dans un subnet public
    connexion SSH depuis ton PC vers le bastion
    puis SSH du bastion vers l’EC2 privée

```text
┌───────────────────────────────────────────────────────────────────────────────┐
│                     ANCIENNE ARCHITECTURE (Avec Bastion Host)                 │
├───────────────────────────────────────────────────────────────────────────────┤
│   🌍 INTERNET                                                                 │
│        │                                                                      │
│        │ SSH (port 22)                                                        │
│        │ Source: Votre IP (var.admin_ip)                                      │
│        ▼                                                                      │
│   ┌───────────────────────────────────────────────────────────────────────┐   │
│   │                      PUBLIC SUBNET                                    │   │ 
│   │   ┌───────────────────────────────────────────────────────────────┐   │   │
│   │   │                    BASTION HOST                               │   │   │
│   │   │                    (aws_instance.bastion_ec2)                 │   │   │
│   │   │                                                               │   │   │
│   │   │   • IP publique : oui                                         │   │   │
│   │   │   • Security Group : bastion_sg                               │   │   │
│   │   │   • Règle entrante : SSH depuis votre IP                      │   │   │
│   │   └───────────────────────────────────────────────────────────────┘   │   │
│   └───────────────────────────────────────────────────────────────────────┘   │
│                                        │                                      │
│                                        │ SSH (port 22)                        │
│                                        │ Source: Bastion SG                   │
│                                        ▼                                      │
│   ┌───────────────────────────────────────────────────────────────────────┐   │
│   │                     PRIVATE SUBNET                                    │   │
│   │   ┌───────────────────────────────────────────────────────────────┐   │   │
│   │   │                 APPLICATION EC2 (PRIVÉE)                      │   │   │
│   │   │                 (aws_instance.app_ec2)                        │   │   │
│   │   │                                                               │   │   │
│   │   │   • IP publique : non                                         │   │   │
│   │   │   • Security Group : private_ec2_sg                           │   │   │
│   │   │   • Règle entrante : SSH depuis Bastion SG                    │   │   │
│   │   └───────────────────────────────────────────────────────────────┘   │   │
│   └───────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
│   ❌ INCONVÉNIENTS :                                                           │
│   • Gérer une instance EC2 supplémentaire (coût)                              │
│   • Gérer des clés SSH (bastion_key_name)                                     │
│   • Maintenance du bastion (mises à jour, sécurité)                           │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

## 🏗️ NOUVELLE ARCHITECTURE  (Avec AWS Systems Manager)
Nouvelle méthode : 
    plus de bastion
    plus de SSH classique obligatoire
    accès via AWS Systems Manager Session Manager
    et les instances de l’application sont gérées par un Auto Scaling Group, donc plus d’EC2 créée “à la main”

```text
┌───────────────────────────────────────────────────────────────────────────────┐
│                   NOUVELLE ARCHITECTURE  (Avec AWS Systems Manager)           │
├───────────────────────────────────────────────────────────────────────────────┤
│   🌍 INTERNET                                                                 │
│        │                                                                      │
│        │ Session Manager (via AWS Console ou CLI)                             │
│        │ Pas besoin d'ouvrir le port 22 !                                     │
│        │ Utilise IAM pour l'authentification                                  │
│        ▼                                                                      │
│   ┌───────────────────────────────────────────────────────────────────────┐   │
│   │                         AWS SYSTEMS MANAGER (SSM)                     │   │
│   │                                                                       │   │
│   │   • Service managé par AWS                                            │   │
│   │   • Pas d'infrastructure à gérer                                      │   │
│   │   • Authentification via IAM                                          │   │
│   │   • Toutes les connexions sont journalisées (CloudTrail)              │   │
│   └───────────────────────────────────────────────────────────────────────┘   │
│                                        │                                      │
│                                        │ Connexion sécurisée                  │
│                                        │ (via SSM Agent)                      │
│                                        ▼                                      │
│   ┌───────────────────────────────────────────────────────────────────────┐   │
│   │                     PRIVATE SUBNET                                    │   │
│   │                                                                       │   │
│   │   ┌───────────────────────────────────────────────────────────────┐   │   │
│   │   │                 APPLICATION EC2 (PRIVÉE)                      │   │   │
│   │   │                 (Gérée par Auto Scaling Group)                │   │   │
│   │   │                                                               │   │   │
│   │   │   • IP publique : non                                         │   │   │
│   │   │   • Security Group : private_ec2_sg                           │   │   │
│   │   │   • Port 22 : FERMÉ (pas besoin !)                            │   │   │
│   │   │   • SSM Agent : installé et actif                             │   │   │
│   │   └───────────────────────────────────────────────────────────────┘   │   │
│   └───────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
│   ✅ AVANTAGES :                                                              │
│   • Pas d'instance bastion à gérer (économies)                                │
│   • Pas de gestion de clés SSH                                                │
│   • Authentification via IAM (plus sécurisé)                                  │
│   • Toutes les actions sont tracées (audit)                                   │
│   • Auto Scaling Group gère les instances (pas de EC2 manuelles)              │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

## Tableau comparatif : Ancienne approche vs Nouvelle approche

```text
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
 Élément	                Ancienne approche (commentée)	   Nouvelle approche (non commentée)
└───────────────────────────────────────────────────────────────────────────────────────────────┘
Bastion Host	        │   ✅ Une instance EC2 publique	        ❌ Plus nécessaire
────────────────────────────────────────────────────────────────────────────────────────────────┘
Application EC2	        │   Instance EC2 manuelle	            Gérée par Auto Scaling Group
────────────────────────────────────────────────────────────────────────────────────────────────┘
Accès SSH	            │   Via Bastion (port 22)	            Via SSM Session Manager
────────────────────────────────────────────────────────────────────────────────────────────────┘
Security Group Bastion	│   bastion_sg avec règle SSH	        ❌ Supprimé
────────────────────────────────────────────────────────────────────────────────────────────────┘
Règle SSH private EC2	│   De Bastion SG → private EC2	        ❌ Plus nécessaire
────────────────────────────────────────────────────────────────────────────────────────────────┘
Clés SSH	            │   bastion_key_name nécessaire	        ❌ Plus nécessaire
────────────────────────────────────────────────────────────────────────────────────────────────┘
IP publique	            │   Bastion = oui / App = non	        App = non (pas de bastion)
────────────────────────────────────────────────────────────────────────────────────────────────┘
Coût	                │   Instance bastion + instance app	    Instance(s) app uniquement
────────────────────────────────────────────────────────────────────────────────────────────────┘
Sécurité	            │   Bonne	                            Meilleure (IAM + audit)
────────────────────────────────────────────────────────────────────────────────────────────────┘
Maintenance	            │   Bastion à patcher	                Rien (SSM est managé)
────────────────────────────────────────────────────────────────────────────────────────────────┘
Port 22 ouvert	        │   Oui (restreint à votre IP)	        ❌ Non (fermé)
────────────────────────────────────────────────────────────────────────────────────────────────┘
Authentification	    │   Clés SSH	                        IAM (avec MFA possible)
────────────────────────────────────────────────────────────────────────────────────────────────┘
Audit des connexions	│   Logs du bastion	                    CloudTrail (intégré)
────────────────────────────────────────────────────────────────────────────────────────────────┘
Scalabilité	            │   Manuelle	                        Automatique (ASG)
────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### Prérequis pour utiliser SSM Session Manager
    - Instance EC2 avec SSM Agent installé
    - IAM Role avec politique AmazonSSMManagedInstanceCore
    - VPC endpoints pour SSM (si instance privée sans accès Internet) 