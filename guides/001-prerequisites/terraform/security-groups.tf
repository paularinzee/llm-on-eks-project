############################################################################
# Security Groups
#
# Learning-guide policy: allow all traffic within the VPC.
# Rules are separate resources (not inline) so the self-reference and the
# cross-SG references don't create cycles or inline/standalone conflicts.
############################################################################

# Control plane SG
resource "aws_security_group" "control_plane" {
  description = "EKS control plane security group"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.cluster_name}-cp-sg"
  }
}

# Node SG - Karpenter's securityGroupSelectorTerms matches on karpenter.sh/discovery
resource "aws_security_group" "node" {
  description = "EKS worker nodes - all VPC traffic allowed for learning environment"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name                     = "${var.cluster_name}-node-sg"
    "karpenter.sh/discovery" = var.cluster_name
  }
}

# --- Node SG rules ---------------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "node_from_vpc" {
  security_group_id = aws_security_group.node.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr
  description       = "Allow all traffic from within VPC (learning env)"
}

resource "aws_vpc_security_group_egress_rule" "node_all_out" {
  security_group_id = aws_security_group.node.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound"
}

resource "aws_vpc_security_group_ingress_rule" "node_self" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.node.id
  description                  = "Allow all node-to-node traffic"
}

resource "aws_vpc_security_group_ingress_rule" "node_from_cp" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.control_plane.id
  description                  = "Allow all from EKS control plane"
}

# --- Control plane SG rules ------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "cp_from_nodes" {
  security_group_id            = aws_security_group.control_plane.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.node.id
  description                  = "Allow HTTPS from worker nodes to control plane"
}

# Terraform strips AWS's default allow-all egress from managed SGs, while CFN keeps it.
# Re-add it here so the control-plane SG behaves like the original template.
resource "aws_vpc_security_group_egress_rule" "cp_all_out" {
  security_group_id = aws_security_group.control_plane.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound (CFN default egress)"
}
