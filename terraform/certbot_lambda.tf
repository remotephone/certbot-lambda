provider "aws" {
  region  = "${var.aws_region}"
  version = ">= 2.12"
  profile = "${var.profile}"
}

resource "random_integer" "id" {
  min = 1000
  max = 9999
}

resource "aws_lambda_function" "certbot_lambda_func" {
  filename      = "certbot.zip"
  function_name = "certbot_lamda-${random_integer.id.result}"
  role          = "${aws_iam_role.lambda_cerbot_iam_role.arn}"
  handler       = "main.lambda_handler"
  timeout       = "720"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("./certbot.zip")

  runtime = "python3.7"

  environment {
    variables = {
      domains   = "${var.domains}"
      email     = "${var.email}"
      s3_bucket = "${var.s3_bucket}"
      s3_prefix = "${var.s3_prefix}"
    }
  }
depends_on = [aws_iam_role.lambda_cerbot_iam_role]

}






# Create base IAM role
resource "aws_iam_role" "lambda_cerbot_iam_role" {
  name               = "lambda-resource-certbot-${random_integer.id.result}"
  assume_role_policy = data.aws_iam_policy_document.lambda_cerbot_iam_policy_doc.json
}

# Add policy enabling access to other AWS services
resource "aws_iam_role_policy" "lambda_cerbot_iam_policy" {
  name   = "lambda-${aws_lambda_function.certbot_lambda_func.id}-${random_integer.id.result}"
  role   = aws_iam_role.lambda_cerbot_iam_role.id
  policy = data.aws_iam_policy_document.lambda_certbot_iam_role_policy.json
}

# JSON POLICY - assume role
data "aws_iam_policy_document" "lambda_cerbot_iam_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "lambda_certbot_iam_role_policy" {

  statement {
    actions = [
      "route53:ListHostedZones",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "cloudwatch:PutMetricData",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "sns:Publish",
      "route53:GetChange",
      "route53:ChangeResourceRecordSets",
    ]
    resources = [
      "${var.sns_topic}",
      "arn:aws:route53:::hostedzone/${var.r53_hosted_zone}",
      "arn:aws:route53:::change/*",
    ]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectVersionAcl",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}/${var.s3_prefix}/*",
    ]
  }
}

resource "aws_cloudwatch_event_rule" "every_15_days" {
    name = "every-fifteen-days"
    description = "Fires every fifteen days"
    schedule_expression = "rate(15 days)"
}

resource "aws_cloudwatch_event_target" "update_certs_every_15_days" {
    rule = "${aws_cloudwatch_event_rule.every_15_days.name}"
    target_id = "certbot_lambda_func"
    arn = "${aws_lambda_function.certbot_lambda_func.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_certbot_lambda_func" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.certbot_lambda_func.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_15_days.arn}"
}