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

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main_eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main_eks_cluster.token
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

data "aws_iam_policy_document" "eks_oidc_assume_role_mlflow" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.eks_cluster_main_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.eks_cluster_main_oidc_provider_name}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.eks_cluster_main_oidc_provider_name}:sub"
      values   = ["system:serviceaccount:${kubernetes_namespace.apps.metadata[0].name}:mlflow"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:AssumeRoleWithWebIdentity",
      "sts:TagSession",
    ]
  }
}

resource "aws_iam_role" "mlflow" {
  name                = "${title(var.project_name)}MLflow"
  managed_policy_arns = [var.policy_mlflow_arn]

  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_mlflow.json
}

resource "kubernetes_service_account" "mlflow" {
  metadata {
    namespace = kubernetes_namespace.apps.metadata[0].name
    name      = "mlflow"
    annotations = merge(local.tags, {
      "eks.amazonaws.com/role-arn" = aws_iam_role.mlflow.arn
    })
  }
}
