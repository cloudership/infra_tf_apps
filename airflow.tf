resource "aws_cloudwatch_log_group" "airflow" {
  name              = "/${var.project_name}/${var.env_name}/airflow/service"
  retention_in_days = 60

  tags = local.tags
}

data "aws_iam_policy_document" "airflow" {
  statement {
    sid = "CreateLogEventsManageCloudWatchLogGroupsAndStreams"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:List*",
      "logs:Get*",
      "logs:Describe*",
    ]

    resources = [
      aws_cloudwatch_log_group.airflow.arn,
      "${aws_cloudwatch_log_group.airflow.arn}:log-stream:*"
    ]
  }

  statement {
    sid = "GenericS3Actions"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

module "service_role_airflow" {
  source       = "./eks_service_role"
  project_name = var.project_name
  tags         = local.tags
  namespace    = "airflow"
  service_account_names = [
    "airflow-create-user-job",
    "airflow-migrate-database-job",
    "airflow-pgbouncer",
    "airflow-scheduler",
    "airflow-triggerer",
    "airflow-webserver",
    "airflow-worker",
    "default",
  ]
  pascal_case_service_name            = "Airflow"
  policy_document_json                = data.aws_iam_policy_document.airflow.json
  eks_cluster_main_oidc_provider_arn  = var.eks_cluster_main_oidc_provider_arn
  eks_cluster_main_oidc_provider_name = var.eks_cluster_main_oidc_provider_name
}

resource "aws_route53_record" "airflow" {
  zone_id = var.route53_zone_public_id
  name    = "airflow"
  type    = "A"

  alias {
    zone_id                = var.alb_public_zone_id
    name                   = var.alb_public_dns_name
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "airflow" {
  name                 = "airflow"
  port                 = 8080
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

resource "aws_lb_listener_rule" "airflow" {
  listener_arn = var.alb_public_https_listener_arn

  condition {
    host_header {
      values = ["airflow.${var.public_domain_prefix}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.airflow.arn
  }

  tags = local.tags
}
