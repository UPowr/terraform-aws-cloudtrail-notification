output "lambda_arn" {
  description = "The ARN from lambda custom message"
  value       = aws_lambda_function.lambda.arn
}

output "alarm_sns_topic" {
  description = "The SNS topic to which CloudWatch Alarms will be sent."
  value       = aws_sns_topic.alarms
}
