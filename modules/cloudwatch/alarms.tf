resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.alb_arn_suffix != "" ? 1 : 0

  alarm_name = "${var.project_name}-${var.environment}-alb-5xx"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10

  alarm_description = "ALB 5XX errors are above threshold"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [
    aws_sns_topic.cloudwatch_alerts.arn
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
