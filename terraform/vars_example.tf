variable "aws_region" {
  description = "Region where AWS resources will be created and used."
  default = "us-east-1"
}

variable "profile" {
  description = "AWS Credential profile terraform will look for."
  default = ""
}

variable "r53_hosted_zone" {
    description = "AWS Route 53 Hosted zone you want subdomain certificates for"
    default = ""
}
variable "domains" {
  description = "Domain to get/renew SSL certificate from LetsEncrypt."
  default = ""
}

variable "email" {
  description = "Email to use to get/renewl SSL certificate from LetsEncrypt."
  default = ""
}

variable "s3_bucket" {
  description = "S3 Bucket where config and keys are stored."
  default = ""
}

variable "sns_topic" {
  description = "SNS topic to publish notifications to."
  default = ""
}

variable "s3_prefix" {
  description = "S3 Path where config and keys are stored."
  default = "live"
}
