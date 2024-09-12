output "bucket_mlflow_name" {
  value = local.mlflow_bucket_name
}

output "policy_mlflow_arn" {
  value = aws_iam_policy.mlflow.arn
}
