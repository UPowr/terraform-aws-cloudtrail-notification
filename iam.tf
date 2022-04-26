data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_cw" {
  name        = "lambda_cw"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:DescribeAlarms"
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:lambda:*:*:*", "arn:aws:logs:*:*:*","arn:aws:cloudwatch:*:*:*"]
      },
      {
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeMetricFilters",
          "logs:FilterLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*",
        Effect : "Allow"
      },
      {
        Action : [
          "SNS:Publish"
        ],
        Resource : "arn:aws:sns:*:*:*",
        Effect : "Allow"
      },
      {
        Action : [
          "kms:Decrypt", "kms:GenerateDataKey*"
        ],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cw" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_cw.arn
}


