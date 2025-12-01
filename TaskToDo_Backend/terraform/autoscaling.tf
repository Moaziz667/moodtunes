# =============================================================================
# Auto-Scaling Group Configuration
# =============================================================================

# Security Group for EC2 instances (only accepts traffic from ALB)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instances in ASG"
  vpc_id      = aws_vpc.main.id

  # SSH access (for debugging - restrict in production)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App traffic ONLY from ALB (more secure!)
  ingress {
    description     = "App traffic from ALB only"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-asg-sg"
  }
}

# Launch Template (replaces direct EC2 instance)
resource "aws_launch_template" "app_template" {
  name_prefix   = "tasktodo-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # IAM instance profile for SSM (optional, for debugging)
  # iam_instance_profile {
  #   name = aws_iam_instance_profile.ec2_profile.name
  # }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    docker_image = var.docker_image
    mongodb_uri  = local.atlas_connection_string
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "tasktodo-asg-instance"
    }
  }

  tags = {
    Name = "tasktodo-launch-template"
  }

  # Update launch template when these change
  lifecycle {
    create_before_destroy = true
  }
}

# Auto-Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "tasktodo-asg"
  desired_capacity    = var.asg_desired_capacity
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  vpc_zone_identifier = [aws_subnet.main_subnet.id, aws_subnet.secondary_subnet.id]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "tasktodo-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Scale UP Policy (add instances when CPU > 70%)
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "tasktodo-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# CloudWatch Alarm for Scale UP
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "tasktodo-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale up when CPU > 70%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

# Scale DOWN Policy (remove instances when CPU < 30%)
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "tasktodo-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# CloudWatch Alarm for Scale DOWN
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "tasktodo-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale down when CPU < 30%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}
