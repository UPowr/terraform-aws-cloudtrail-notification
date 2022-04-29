resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/lambda.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  timeout       = var.lambda_timeout
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
  runtime = "nodejs12.x"
  tags = var.tags
  environment {
    variables = {
      LOG_GROUP = var.cloudtrail_log_group_name,
      TOPIC_ARN=var.aws_sns_topic_arn,
      OFFSET=180
    }
  }
}

resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_notification.arn
}

resource "aws_cloudwatch_log_group" "alarm_lambda" {
  name = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 14
  tags = var.tags
}