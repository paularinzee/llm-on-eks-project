# Remote state in S3 with native lockfile locking (Terraform >= 1.10; no DynamoDB needed).
#
# Backend blocks can't use variables, so the environment-specific values live in
# backend.hcl (see backend.hcl.example) and are passed at init time:
#
#   terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {
    key          = "llms-on-eks/eks-karpenter/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
    # bucket and region come from backend.hcl
  }
}
