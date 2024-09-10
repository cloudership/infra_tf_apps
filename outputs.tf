output "bucket_mlflow_name" {
  value = local.mlflow_bucket_name
}

output "role_mlflow_arn" {
  value = aws_iam_role.mlflow.arn
}
