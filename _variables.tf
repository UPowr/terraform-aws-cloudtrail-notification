variable "enabled" {
  description = "The boolean flag whether this module is enabled or not. No resources are created when set to false."
  default     = true
}

variable "lambda_name" {
  description = "The name of the lambda which will be notified with a custom message when any alarm is performed."
  default     = "lambda_alarm_notification"
}

variable "cloudtrail_log_group_name" {
  description = "The name of the loggroup that will get information from"
}

variable "lambda_timeout" {
  description = "Set lambda Timeout"
  default = 3
}

variable "sns_topic_name" {
  description = "The name of the SNS Topic which will be notified when any alarm is performed."
  default     = "CISAlarmV2"
} 

variable "alarm_account_ids" {
  default = []
}

variable "alarm_mode" {
  default     = "light"
  description = "Version of alarms to use. 'light' or 'full' available"
}

variable "tags" {
  description = "Specifies object tags key and value. This applies to all resources created by this module."
  default = {
    "Terraform" = true
  }
}

