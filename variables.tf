variable "project_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "bucket_prefix" {
  type        = string
  description = "Bucket prefix for S3 buckets - append it with a '-' before bucket names"
}

variable "rds_hostname" {
  description = "Hostname of the base RDS instance"
}

variable "rds_port" {
  description = "Port of the base RDS instance"
  type        = number
}

variable "eks_cluster_main_name" {
  type = string
}

variable "eks_cluster_main_oidc_provider_name" {
  type = string
}

variable "eks_cluster_main_oidc_provider_arn" {
  type = string
}
