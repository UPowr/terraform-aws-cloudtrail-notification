resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  timeout       = var.lambda_timeout
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
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
  tags = var.tags
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_cloudwatch_log_group" "alarm_lambda" {
  name = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 14
  tags = var.tags
}