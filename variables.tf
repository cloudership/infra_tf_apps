variable "project_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "bucket_prefix" {
  description = "Bucket prefix for S3 buckets - append it with a '-' before bucket names"
}
