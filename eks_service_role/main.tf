data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  tags = var.tags
}

resource "aws_iam_policy" "this" {
  name   = "${title(var.project_name)}${var.pascal_case_service_name}"
  policy = var.policy_document_json

  tags = local.tags
}

data "aws_iam_policy_document" "eks_oidc_assume_role" {
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
      values   = ["system:serviceaccount:${var.namespace}:${var.service_name}"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:AssumeRoleWithWebIdentity",
      "sts:TagSession",
    ]
  }
}

resource "aws_iam_role" "this" {
  name                = "${title(var.project_name)}${var.pascal_case_service_name}"
  managed_policy_arns = [aws_iam_policy.this.arn]

  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role.json

  tags = local.tags
}
