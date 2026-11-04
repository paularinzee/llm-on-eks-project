data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  oidc_issuer = aws_eks_cluster.this.identity[0].oidc[0].issuer
  oidc_host   = replace(local.oidc_issuer, "https://", "")

  # CFN: !Select [0|1, !GetAZs '']
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}
