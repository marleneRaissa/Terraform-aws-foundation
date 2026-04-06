# ------------------------------------------------------------------------------------------------- #
# instance Target Group : C'est un groupe qui regroupe des cibles (instances EC2, conteneurs, IPs) 
# qui recevront le trafic du load balancer.
# Le load balancer va envoyer le trafic vers les instances EC2 sur leur port 80
# Les instances EC2 doivent avoir un serveur web (Nginx, Apache, etc.) qui écoute sur le port 80
# Quand l'utiliser :
# Quand vous avez plusieurs instances backend qui doivent recevoir du trafic de façon équilibrée
# Pour séparer différentes applications sur le même load balancer (ex: un target group pour l'API, un autre pour le frontend)
# Pour configurer des health checks personnalisés (ex: vérifier /api/health plutôt que juste /)
# ------------------------------------------------------------------------------------------------- #
resource "aws_lb_target_group" "app_tg" {
  name        = "lab04-app-tg"
  port        = 80                        # ← Les instances EC2 doivent écouter sur ce port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id  # qui : Est associé au VPC défini dans un état distant Terraform
  target_type = "instance"                                      # qui : Cible des instances EC2 (type "instance")

  // Comment vérifier la santé des cibles (health checks)
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check
  health_check {
    path                = "/"   # Vérifie la racine / toutes les 30 secondes
    protocol            = "HTTP"
    matcher             = "200" # Attend une réponse HTTP 200 pour considérer l'instance comme saine → healthy
    interval            = 30    # Every 30 seconds, the ALB checks again.
    timeout             = 6     # The EC2 must respond within 6 seconds.
    healthy_threshold   = 3     # The EC2 must pass 3 consecutive checks to become healthy.
    unhealthy_threshold = 3     # The EC2 must fail 3 consecutive checks to be removed.

  }

  tags = {
    Name    = "lab04-app-tg"
    Env     = "dev"
    Project = "lab04-alb"
  }

}

// not required anymore, performing a terraform destroy
/*
# add ec2 (private app ec2) to target group
resource "aws_lb_target_group_attachment" "app_ec2" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = data.terraform_remote_state.compute.outputs.app_ec2_id
  port             = 80
}
*/


# ------------------------------------------------------------------------------------------------- #
# Provides a Load Balancer Listener resource.
# Crée un écouteur sur le load balancer qui Écoute sur le port 80 en HTTP du LB,
# Et Redirige tout le trafic vers HTTPS (port 443) avec un code de redirection 301 (redirection permanente)
# ------------------------------------------------------------------------------------------------- #
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn    # identifiant unique géré par amazon pour identifier une ressource de facon unique
  port              = "80"              # ← Load Balancer écoute sur le port 80
  protocol          = "HTTP"

  // HTTP → HTTPS Redirect
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"  // La ressource que vous cherchez a été déplacée définitivement à une nouvelle adresse. Allez là-bas ! (cfère lab05)
    }
  }
}