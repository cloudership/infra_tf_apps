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
  role_mlflow_arn       = aws_iam_role.mlflow.arn

  config_namespace_apps = {
    DB_HOSTNAME         = var.rds_hostname
    DB_PORT             = var.rds_port
    MLFLOW_BUCKET_NAME  = local.mlflow_bucket_name
    MLFLOW_TARGET_GROUP = aws_lb_target_group.mlflow.arn
  }
}
