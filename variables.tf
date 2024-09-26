variable "project_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" { type = string }

variable "public_domain_prefix" { type = string }

variable "bucket_prefix" {
  type        = string
  description = "Bucket prefix for S3 buckets - append it with a '-' before bucket names"
}

variable "rds_hostname" {
  description = "Hostname of the base RDS instance"
}

variable "rds_port" {
  description = "Port of the base RDS instance"
  type        = number
}

variable "eks_cluster_main_name" {
  type = string
}

variable "eks_cluster_main_oidc_provider_name" {
  type = string
}

variable "eks_cluster_main_oidc_provider_arn" {
  type = string
}

variable "eks_cluster_main_sg_id" { type = string }

variable "alb_public_zone_id" { type = string }

variable "alb_public_dns_name" { type = string }

variable "alb_public_https_listener_arn" { type = string }

variable "route53_zone_public_id" { type = string }
