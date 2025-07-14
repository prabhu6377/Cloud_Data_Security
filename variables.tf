variable "bucket_name" {
  description = "The name of the S3 bucket to scan"
  type        = string
}

variable "job_name" {
  description = "The name of the Macie classification job"
  type        = string
  default     = "macie-classification-job"
}