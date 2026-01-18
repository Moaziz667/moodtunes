# =============================================================================
# 🎬 CONFIGURATION AUTOSCALING POUR DÉMO VIDÉO
# =============================================================================
# Cette configuration a des temps réduits pour une démo plus rapide
# À utiliser uniquement pour la démo, pas en production!
# =============================================================================

# Scale UP Policy - DÉMO (cooldown réduit)
resource "aws_autoscaling_policy" "scale_up_demo" {
  name                   = "tasktodo-scale-up-demo"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60  # 1 minute au lieu de 5
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# CloudWatch Alarm for Scale UP - DÉMO (évaluation plus rapide)
resource "aws_cloudwatch_metric_alarm" "cpu_high_demo" {
  alarm_name          = "tasktodo-cpu-high-demo"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1  # 1 période au lieu de 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60  # 1 minute au lieu de 2
  statistic           = "Average"
  threshold           = 50  # 50% au lieu de 70% (plus facile à déclencher)
  alarm_description   = "DEMO - Scale up when CPU > 50%"
  alarm_actions       = [aws_autoscaling_policy.scale_up_demo.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  tags = {
    Environment = "demo"
  }
}

# Scale DOWN Policy - DÉMO (cooldown réduit)
resource "aws_autoscaling_policy" "scale_down_demo" {
  name                   = "tasktodo-scale-down-demo"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60  # 1 minute au lieu de 5
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# CloudWatch Alarm for Scale DOWN - DÉMO
resource "aws_cloudwatch_metric_alarm" "cpu_low_demo" {
  alarm_name          = "tasktodo-cpu-low-demo"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20  # 20% au lieu de 30%
  alarm_description   = "DEMO - Scale down when CPU < 20%"
  alarm_actions       = [aws_autoscaling_policy.scale_down_demo.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  tags = {
    Environment = "demo"
  }
}
