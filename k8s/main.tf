data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = {
    Component = "apps_k8s"
  }
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name        = "apps"
    annotations = local.tags
  }
}

resource "kubernetes_config_map" "apps_iac_config" {
  metadata {
    namespace   = kubernetes_namespace.apps.metadata[0].name
    name        = "iac-config"
    annotations = local.tags
  }

  data = {
    DB_HOSTNAME        = var.rds_hostname
    DB_PORT            = var.rds_port
    MLFLOW_BUCKET_NAME = var.bucket_mlflow_name
  }
}

resource "kubernetes_service_account" "mlflow" {
  metadata {
    namespace   = kubernetes_namespace.apps.metadata[0].name
    name        = "mlflow"
    annotations = local.tags
  }
}

resource "aws_eks_pod_identity_association" "mlflow" {
  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace.apps.metadata[0].name
  service_account = kubernetes_service_account.mlflow.metadata[0].name
  role_arn        = var.role_mlflow_arn

  tags = local.tags
}
