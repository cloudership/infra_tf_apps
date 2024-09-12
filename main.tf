data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  mlflow_bucket_name = "${var.bucket_prefix}-mlflow"

  tags = {
    Component = "apps"
  }
}
