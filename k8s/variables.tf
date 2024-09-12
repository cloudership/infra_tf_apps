variable "project_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "rds_hostname" {
  description = "Hostname of the base RDS instance"
}

variable "rds_port" {
  description = "Port of the base RDS instance"
  type        = number
}

variable "bucket_mlflow_name" {
  type = string
}

variable "policy_mlflow_arn" {
  type = string
}

variable "eks_cluster_main_oidc_provider_name" {
  type = string
}

variable "eks_cluster_main_oidc_provider_arn" {
  type = string
}
