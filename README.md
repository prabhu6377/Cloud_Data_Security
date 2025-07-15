# 🔐 Automated Sensitive Data Classification in S3 using Amazon Macie + Terraform

This project demonstrates how to detect and secure sensitive data (like PII) in Amazon S3 using Amazon Macie and automate remediation with AWS Lambda and EventBridge — all provisioned through Terraform.

---

## 📌 Project Goals

- Classify and detect sensitive data in S3
- Use Terraform to provision Macie, IAM, Lambda, and EventBridge
- Auto-remediate exposed S3 buckets (set ACL to private)
- Learn Infrastructure as Code (IaC) patterns for cloud security

---

## 🛠️ Services & Tools Used

- **Amazon S3** – Test data storage
- **Amazon Macie** – Sensitive data classification
- **AWS Lambda** – Auto-remediation function
- **EventBridge** – Macie findings trigger Lambda
- **Terraform** – Declarative infrastructure management
- **IAM** – Access roles and policies
- **AWS CLI** – Authentication and configuration

---

## 🧪 Test Data

S3 test files included:
- `contacts.csv` – Simulated names, emails, phone numbers
- `dummy_pii.txt` – Contains realistic but fake PII values

---

## 📁 Folder Structure

```bash
macie-project/
├── main.tf              # Core infrastructure (Macie, S3, Lambda, EventBridge)
├── variables.tf         # Input variable definitions
├── terraform.tfvars     # Values for variables
├── lambda/
│   └── auto_remediate.py  # Lambda code to set bucket ACL to private
├── README.md
```

---

## ✅ Key Terraform Concepts

- `aws_macie2_classification_job`: Scans for PII using managed data identifiers
- `aws_lambda_function`: Deployed from zipped Python file
- `archive_file`: Packages the Lambda code into a .zip
- `aws_cloudwatch_event_rule`: Listens for Macie findings
- `aws_cloudwatch_event_target`: Triggers Lambda
- `aws_lambda_permission`: Allows EventBridge to invoke Lambda

---

## ⚙️ Auto-Remediation Flow

1. Macie scans S3 for sensitive data
2. A finding is generated
3. EventBridge rule triggers Lambda
4. Lambda checks the affected bucket and sets ACL to `private`

---

## 🔄 How to Deploy

```bash
# Initialize project
terraform init

# (Optional) Preview the plan
terraform plan

# Apply infrastructure
terraform apply
```

> Note: For recurring scans, use `job_type = "SCHEDULED"` instead of `"ONE_TIME"`.

---

## 🧹 Cleanup

```bash
terraform destroy
```

> Macie completed jobs cannot be deleted — they remain in the account history.

---

## 🧠 What I Learned

- How Macie detects PII with managed data identifiers
- How Terraform treats state and immutable AWS resources
- How to integrate Lambda and EventBridge for auto-remediation
- That not all AWS services support full CRUD operations via Terraform!

---

## 🏷️ Tags

`#AWS` `#Terraform` `#Macie` `#S3` `#CloudSecurity` `#DevSecOps` `#IaC` `#AutoRemediation` `#Cloudica`

---

## 📎 Credits

This project is part of the **Cloudica Security Showcase** – practical security automation for cloud-native architectures.