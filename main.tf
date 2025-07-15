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
  managed_data_identifier_ids = ["ALL"]

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [var.bucket_name]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = var.bucket_name

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
