variable "enabled" {
  description = "The boolean flag whether this module is enabled or not. No resources are created when set to false."
  default     = true
}

variable "lambda_alarm_name" {
  description = "The name of the lambda which will be notified with a custom message when any alarm is performed."
  default     = "lambda_alarm_notification"
}

variable "cloudtrail_log_group_name" {
  description = "The name of the loggroup that will get information from"
}

variable "aws_sns_topic_arn" {
  description = "The ARN of SNS Topic where the notification will be sent"
}

variable "tags" {
  description = "Specifies object tags key and value. This applies to all resources created by this module."
  default = {
    "Terraform" = true
  }
}
