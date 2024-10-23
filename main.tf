data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = {
    Component = "apps"
  }
}

module "apps_k8s" {
  source                = "./k8s"
  aws_region            = var.aws_region
  env_name              = var.env_name
  project_name          = var.project_name
  eks_cluster_main_name = var.eks_cluster_main_name
  role_mlflow_arn       = module.service_role_mlflow.role_arn

  config_namespace_apps = {
    MLFLOW_BUCKET_NAME = local.mlflow_bucket_name
  }
}
