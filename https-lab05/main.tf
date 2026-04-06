# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate


# ACM Certificate for HTTPS (ALB)
# Sécurité : Chiffre les données entre le client et l'ALB (protection contre l'interception)
# Confiance utilisateur : Évite les avertissements "site non sécurisé" dans les navigateurs
# Gratuit : Les certificats ACM pour ALB/CloudFront sont sans frais supplémentaires
# Renouvellement automatique : ACM gère le renouvellement (contrairement aux certificats manuels)
resource "aws_acm_certificate" "cert" {
  domain_name               = "leadrisehq.com"      // Certificat principal pour le domaine racine
  subject_alternative_names = ["*.leadrisehq.com"] // Également valide pour tous les sous-domaines
  validation_method         = "DNS"

  tags = {
    Name    = "lab05-https"
    Env     = "dev"
    Project = "lab05-https"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# ------------------------------------------  Pourquoi l'utiliser ?  -------------------------------------------------- #
# Terminaison TLS : L'ALB gère le déchiffrement HTTPS, déchargeant les serveurs d'application
# Centralisation : Un seul certificat géré au niveau du load balancer
# Performance : L'ALB optimise le traitement TLS mieux que des serveurs applicatifs
# Flexibilité : Peut avoir des règles différentes (ex: redirection HTTP→HTTPS, routing basé sur path)
# Compatibilité : Fonctionne avec n'importe quelle application (même celles qui ne parlent que HTTP en interne)
# --------------------------------------------------------------------------------------------------------------------- #
# Crée un listener HTTPS sur l'ALB (Application Load Balancer) qui écoute le port 443 et termine la connexion TLS
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = data.terraform_remote_state.alb.outputs.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09" # Recommended
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.alb.outputs.app_tg_arn
  }
}