variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "namespace" {
  type = string
}

variable "service_account_names" {
  type        = list(string)
  description = "List of EKS service account names that can assume the generated role"
}

variable "pascal_case_service_name" {
  type        = string
  description = "Used in IAM names (e.g. MLflow for mlflow)"
}

variable "policy_document_json" {
  type        = string
  description = "A JSON string that defines the policy document to attach to the role"
}

variable "eks_cluster_main_oidc_provider_arn" {
  type = string
}

variable "eks_cluster_main_oidc_provider_name" {
  type = string
}
