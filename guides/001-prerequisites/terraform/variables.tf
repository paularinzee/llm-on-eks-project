variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_tag" {
  description = "Tag applied to all resources"
  type        = string
  default     = "llms-on-eks"
}

variable "cluster_name" {
  description = "EKS cluster name - must be unique in the region"
  type        = string
  default     = "llms-on-eks"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_1_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "private_subnet_1_cidr" {
  type    = string
  default = "10.20.10.0/24"
}

variable "private_subnet_2_cidr" {
  type    = string
  default = "10.20.11.0/24"
}

variable "system_node_instance_type" {
  type    = string
  default = "t3.medium"

  validation {
    condition     = contains(["t3.medium", "t3.large", "t3.xlarge"], var.system_node_instance_type)
    error_message = "Must be one of: t3.medium, t3.large, t3.xlarge."
  }
}

variable "system_node_desired_size" {
  type    = number
  default = 2
}

variable "system_node_min_size" {
  type    = number
  default = 2
}

variable "system_node_max_size" {
  type    = number
  default = 4
}
