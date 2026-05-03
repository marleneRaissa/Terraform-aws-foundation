resource "aws_autoscaling_policy" "scale_out" {
  name                   = "lab07-asp-scale-out"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1                      # Add 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = data.terraform_remote_state.autoscaling.outputs.autoscaling_group_name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "lab07-asp-scale-in"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1                     # Remove 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = data.terraform_remote_state.autoscaling.outputs.autoscaling_group_name
}

# CPU > 60% for 2 minutes
resource "aws_cloudwatch_metric_alarm" "cpu_above_60" {
  alarm_name          = "lab07-cpu-above-60"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2" # Service: Amazon EC2
  period              = 120       # 120 sec = 2 min
  statistic           = "Average"
  threshold           = 60
  treat_missing_data  = "missing"

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.autoscaling.outputs.autoscaling_group_name
  }

  alarm_description = "This metric monitors ec2 cpu utilization and trigger when CPU > 60% for 2 min."
  alarm_actions     = [aws_autoscaling_policy.scale_out.arn]
}

# CPU < 20% for 5 minutes
resource "aws_cloudwatch_metric_alarm" "cpu_below_20" {
  alarm_name          = "lab07-cpu-below-20"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2" # Service: Amazon EC2
  period              = 300
  statistic           = "Average"
  threshold           = 20
  treat_missing_data  = "missing"

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.autoscaling.outputs.autoscaling_group_name
  }

  alarm_description = "This metric monitors ec2 cpu utilization and  trigger when CPU < 20% for 5 min."
  alarm_actions     = [aws_autoscaling_policy.scale_in.arn]
}