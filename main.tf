locals {
  mlflow_bucket_name = "${var.bucket_prefix}-mlflow"
}

module "bucket_mlflow" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket = local.mlflow_bucket_name
}
