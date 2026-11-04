# EKS 1.32 + Karpenter prerequisites (Terraform)

Terraform port of `eks-karpenter.yaml` (CloudFormation). Learning environment only:
broad IAM, allow-all NACLs, and VPC-wide security group ingress.

## Usage

State is stored in S3 (native lockfile locking, so Terraform >= 1.10 is required).

    # 1. One-time: create the state bucket (uses local state)
    cd bootstrap
    terraform init && terraform apply
    cd ..

    # 2. Point the main stack at it (paste the bucket name from step 1)
    cp backend.hcl.example backend.hcl

    # 3. Deploy
    cp terraform.tfvars.example terraform.tfvars
    terraform init -backend-config=backend.hcl
    terraform apply

    aws eks update-kubeconfig --name llms-on-eks --region us-east-1

## File map

| File | CloudFormation resources |
|---|---|
| `vpc.tf` | VPC, IGW, subnets, NAT, route tables, NACLs |
| `security-groups.tf` | Control-plane and node SGs + rules |
| `iam.tf` | Control-plane, node group, EBS CSI roles, OIDC provider |
| `eks.tf` | Cluster, add-ons, system node group |
| `karpenter.tf` | Node role, controller policy/role, access entry, SQS, EventBridge |
| `backend.tf` | S3 remote state (bucket/region supplied via `backend.hcl`) |
| `bootstrap/` | One-time config that creates the versioned, encrypted state bucket |
| `outputs.tf` | Outputs (CFN `Export`s become plain outputs) |

## Differences from the CFN template

- `project` tag applied via provider `default_tags` (covers every taggable resource).
- IGW attachment is implicit; `DependsOn` is expressed via references or `depends_on`.
- SG rules are standalone rules; I added an explicit allow-all egress on the control-plane SG
  because Terraform removes AWS's default egress rule (CFN keeps it).
- Region is the `region` variable (CFN used the stack's region).
- Managed policies are attached with `aws_iam_role_policy_attachment`.
