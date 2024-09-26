variable "project_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "eks_cluster_main_name" {
  type = string
}

variable "role_mlflow_arn" {
  type = string
}

variable "config_namespace_apps" {
  type = map(string)
}
