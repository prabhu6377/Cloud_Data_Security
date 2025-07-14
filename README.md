# 🔐 Amazon Macie S3 Data Classification with Terraform

## 📘 Overview

This project uses Amazon Macie to scan an S3 bucket for sensitive data such as emails, names, and contact details. The infrastructure is fully automated using Terraform.

## 🎯 Goals

- Automate classification of sensitive data in S3 using Macie
- Manage infrastructure using Terraform
- Interpret Macie findings for compliance insights

## 🛠️ Technologies Used

- **Amazon S3**
- **Amazon Macie**
- **Terraform v1.8.5**
- **AWS CLI**
- **IAM**

## 📁 Project Structure

```
macie-project/
├── main.tf             # Core Macie job setup
├── variables.tf        # Input variable definitions
├── terraform.tfvars    # Actual input values
└── README.md           # This documentation
```

## 🔧 Terraform Configuration

### `main.tf`

```hcl
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
```

### `variables.tf`

```hcl
variable "bucket_name" {
  description = "The name of the S3 bucket to scan"
  type        = string
}

variable "job_name" {
  description = "The name of the Macie classification job"
  type        = string
  default     = "macie-classification-job"
}
```

### `terraform.tfvars`

```hcl
bucket_name = "macie-test-bucket-prabhu"
job_name    = "macie-classification-job"
```

## ✅ How to Run

```bash
terraform init
terraform plan
terraform apply
```

After apply, go to the **AWS Console → Macie → Jobs** to monitor progress and view findings.

## 🧠 Key Learning Outcomes

- Cloud-native data classification
- Terraform IaC best practices
- Security automation workflows
- Integration of S3 and Macie for compliance scanning

## 📌 Status

✅ Working and validated on Terraform v1.8.5 with AWS Provider v6.3.0

---

## 📩 Let’s Connect

Feel free to connect with me or ask questions — I’m always happy to share knowledge and learn together!

---

## 🏷️ Tags

`#AWS` `#Macie` `#Terraform` `#CloudSecurity` `#IaC` `#S3` `#DataPrivacy` `#DevSecOps`
