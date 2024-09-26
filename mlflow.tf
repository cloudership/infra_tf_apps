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

  tags = local.tags
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
      values   = ["system:serviceaccount:apps:mlflow"]
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
  managed_policy_arns = [aws_iam_policy.mlflow.arn]

  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_mlflow.json

  tags = local.tags
}

resource "aws_route53_record" "mlflow" {
  zone_id = var.route53_zone_public_id
  name    = "mlflow"
  type    = "A"

  alias {
    zone_id                = var.alb_public_zone_id
    name                   = var.alb_public_dns_name
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "mlflow" {
  name                 = "mlflow"
  port                 = 5000
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 5

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    path                = "/health"
    protocol            = "HTTP"
  }

  tags = local.tags
}

resource "aws_lb_listener_rule" "mlflow" {
  listener_arn = var.alb_public_https_listener_arn

  condition {
    host_header {
      values = ["mlflow.${var.public_domain_prefix}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mlflow.arn
  }

  tags = local.tags
}
