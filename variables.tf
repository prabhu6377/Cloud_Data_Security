variable "bucket_name" {
  description = "The name of the S3 bucket to scan"
  type        = string
}

variable "job_name" {
  description = "The name of the Macie classification job"
  type        = string
  default     = "macie-classification-job"
}
variable "log_bucket" {
  description = "The name of the S3 buvket where access logs will be stored"
  type        = string
}

variable "alert_email" {
  description = "Email address to receive Macie alerts"
  type        = string
}
