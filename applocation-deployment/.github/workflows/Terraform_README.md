# Step -1: 🚀 Terraform GitHub Actions Deployment
This repository uses GitHub Actions to automate your Terraform infrastructure deployments. This includes:

- Terraform formatting

- Initialization

- Validation

- Plan

- Apply / Destroy

- rtifact uploads for plan and errored state

## 📂 Workflow File: .github/workflows/terraform.yaml
This workflow is manually triggered via workflow_dispatch and supports both creation and destruction of resources based on environment variables.

## ✅ Prerequisites
### 1. GitHub Secrets
Add the following secrets to your repository `(Settings > Secrets and variables > Actions)`:

- `AWS_ACCESS_KEY_ID` : AWS access key with permissions to deploy
- `AWS_SECRET_ACCESS_KEY` : AWS secret key
- `AWS_SESSION_TOKEN` : Optional – For temporary credentials
- `BUILD_ROLE` : IAM role ARN to assume during deployment
### 🌐 Required env Variables (define in workflow or via GitHub Actions UI)
Add these as Environment Variables `(either globally in the workflow or in the GitHub UI under Actions > Variables)`:

- `provider` :	Cloud provider name (e.g., aws)
- `aws_region` :	AWS region to deploy to (e.g., us-east-1)
- `terraform_version` :	Terraform version to use (e.g., 1.6.0)
- `working_directory` :	Path where Terraform config files are located (e.g., infra/terraform)
- `destroy` :	Set to true to run terraform destroy, or false/leave unset to apply
var_file	Optional – path to a .tfvars file for variable overrides (e.g., prod.tfvars)
### 📋 Example workflow_dispatch Usage
You can trigger the workflow manually from the GitHub UI and set environment variables like:

``` yaml
env:
  provider: aws
  aws_region: us-east-1
  terraform_version: 1.6.0
  working_directory: infra/terraform
  destroy: false
  var_file: prod.tfvars
```
***To destroy infrastructure:***

```yaml
env:
  provider: aws
  aws_region: us-east-1
  terraform_version: 1.6.0
  working_directory: infra/terraform
  destroy: true
  var_file: prod.tfvars
```
## ⚙️ Workflow Breakdown
### ➤ Terraform Format
Ensures Terraform code is formatted correctly using terraform fmt.

### ➤ Terraform Init
Initializes the Terraform working directory.

### ➤ Terraform Validate
Validates your Terraform configuration files.

### ➤ Terraform Plan
Creates an execution plan and uploads it as an artifact.

### ➤ Apply
Applies the Terraform plan automatically if destroy != true.

### ➤ Destroy
Destroys infrastructure if destroy == true.

### ➤ Errored State
If Terraform fails and creates errored.tfstate, it is uploaded as an artifact.


## 🧪 Triggering Manually
Go to `Actions → Terraform workflow → Run workflow` and fill in:

- `aws_region:` us-east-1

- `working_directory:` infra/terraform

- `terraform_version:` 1.6.0

-  `var_file:` prod.tfvars

- `destroy:` false (or true to destroy)

## 🛑 Notes
- This workflow supports both apply and destroy logic.

- You must maintain your .tf and .tfvars files in the correct directory as defined by working_directory.

- Make sure the role in BUILD_ROLE has permission to perform Terraform operations (S3, EC2, VPC, etc. as required).

