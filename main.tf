provider "aws" {
  region = "ap-south-1"
}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "target" {
  bucket = var.bucket_name
}

resource "aws_macie2_classification_job" "s3_scan" {
  name                = var.job_name
  job_type            = "ONE_TIME"
  initial_run         = true
  sampling_percentage = 100
#  managed_data_identifier_ids = ["ALL"]

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [var.bucket_name]
    }
  }
}

# Automatically Make Public S3 Buckets Private

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = var.bucket_name

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Enable Default Encryption on S3 Buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = var.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable Access Logging for Auditing

resource "aws_s3_bucket_logging" "access_logs" {
  bucket = var.bucket_name

  target_bucket = var.log_bucket
  target_prefix = "access-logs/"
}

# Attach S3 Bucket Policy to Deny Non-Encrypted Uploads
/*
resource "aws_s3_bucket_policy" "deny_unencrypted" {
  bucket = var.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnEncryptedObjectUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${var.bucket_name}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      }
    ]
  })
}
*/
# Create an SNS Topic + Email Subscription

resource "aws_sns_topic" "macie_alerts" {
  name = "macie-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.macie_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email  # e.g. you@example.com
}

# Create an EventBridge Rule to Catch Macie Findings

resource "aws_cloudwatch_event_rule" "macie_findings" {
  name        = "macie-finding-rule"
  description = "Trigger on new Macie findings"

  event_pattern = jsonencode({
    source      = ["aws.macie2"],
    "detail-type" = ["Macie Finding"]
  })
}

# Connect the Rule to SNS Topic

resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.macie_findings.name
  target_id = "sendToSNS"
  arn       = aws_sns_topic.macie_alerts.arn
}
/*
# IAM Permission for EventBridge to Publish to SNS

resource "aws_lambda_permission" "eventbridge_to_sns" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.auto_remediate.function_name
  source_arn    = aws_cloudwatch_event_rule.macie_findings.arn
}
*/
# Define the Lambda Function in Terraform
resource "aws_lambda_function" "auto_remediate" {
  function_name = "macie_auto_remediate"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "auto_remediate.lambda_handler"
  runtime       = "python3.10"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
# AWS lambda Execution Role.
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Inline Policy
resource "aws_iam_policy" "custom_access" {
  name = "LambdaS3MaciePolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = "arn:aws:s3:::macie-test-bucket-prabhu/*"
      },
      {
        Effect   = "Allow",
        Action   = ["macie2:GetFindings", "macie2:ListFindings"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_custom_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.custom_access.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/auto_remediate.py"
  output_path = "${path.module}/lambda/auto_remediate.zip"
}
/*

resource "aws_cloudwatch_event_rule" "macie_findings" {
  name        = "macie-finding-rule"
  description = "Trigger Lambda on Macie findings"
  event_pattern = jsonencode({
    "source": ["aws.macie2"],
    "detail-type": ["Macie Finding"]
  })
}
*/

resource "aws_cloudwatch_event_target" "macie_lambda_target" {
  rule      = aws_cloudwatch_event_rule.macie_findings.name
  target_id = "macie-auto-remediate"
  arn       = aws_lambda_function.auto_remediate.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_remediate.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.macie_findings.arn
}
