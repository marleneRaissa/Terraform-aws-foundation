output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

# il permettra ensuite à d’autres ressources dans le lab06 , comme un Auto Scaling Group, de dire :
# “Mes instances doivent être ajoutées dans ce Target Group de l’ALB.
output "app_tg_arn" {
  value = aws_lb_target_group.app_tg.arn
}
