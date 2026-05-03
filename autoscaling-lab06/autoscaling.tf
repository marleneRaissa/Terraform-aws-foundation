# Provides an Auto Scaling Group resource.
resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  target_group_arns   = [data.terraform_remote_state.alb.outputs.app_tg_arn]  # Rattache mes instances/ressource que je crée au Target Group de l’ALB dont l’ARN est récupéré depuis le remote state Terraform du lab04
                                                                              # Les instances EC2 que tu crées doivent être ajoutées automatiquement dans ce Target Group, Et comme ce Target Group est relié à ton ALB, alors l’ALB pourra envoyer le trafic vers ces instances.
  min_size         = 1
  desired_capacity = 2
  max_size         = 3

  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = var.extra_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}

# You can use tags to classify auto scaling groups—for example to indicate their purpose, the environment 
# they run in, or their owner. You can add several tags to a single group, and specify that tags should 
# also be applied to the individual EC2 instances inside the group. This can help break down instance 
# costs in your EC2 bill.
