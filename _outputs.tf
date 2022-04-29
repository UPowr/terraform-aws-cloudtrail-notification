output "lambda_arn" {
  description = "The ARN from lambda custom message"
  value       = aws_lambda_function.lambda.arn
}
