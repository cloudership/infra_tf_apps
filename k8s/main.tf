data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = {
    Component = "apps_k8s"
  }
}

data "aws_eks_cluster" "main_eks_cluster" {
  name = var.eks_cluster_main_name
}

data "aws_eks_cluster_auth" "main_eks_cluster" {
  name = var.eks_cluster_main_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main_eks_cluster.token
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name        = "apps"
    annotations = local.tags
  }
}

resource "kubernetes_config_map" "apps_iac_config" {
  metadata {
    namespace   = "apps"
    name        = "iac-config"
    annotations = local.tags
  }

  data = var.config_namespace_apps
}

resource "kubernetes_service_account" "mlflow" {
  metadata {
    namespace = "apps"
    name      = "mlflow"
    annotations = merge(local.tags, {
      "eks.amazonaws.com/role-arn" = var.role_mlflow_arn
    })
  }
}
