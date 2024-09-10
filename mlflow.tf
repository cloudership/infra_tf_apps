module "bucket_mlflow" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket = local.mlflow_bucket_name

  tags = local.tags
}

data "aws_iam_policy_document" "mlflow" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:List*",
      "s3:Delete*",
    ]

    resources = [
      "arn:aws:s3:::${local.mlflow_bucket_name}",
      "arn:aws:s3:::${local.mlflow_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "mlflow" {
  name   = "${title(var.project_name)}MLflow"
  policy = data.aws_iam_policy_document.mlflow.json
}

resource "aws_iam_role" "mlflow" {
  name                = "${title(var.project_name)}MLflowPod"
  assume_role_policy  = data.aws_iam_policy_document.eks_pod_identity_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.mlflow.arn]
}
