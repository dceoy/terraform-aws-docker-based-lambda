output "s3_io_s3_bucket_id" {
  description = "S3 IO S3 bucket ID"
  value       = aws_s3_bucket.io.id
}

output "s3_log_s3_bucket_id" {
  description = "S3 log S3 bucket ID"
  value       = length(aws_s3_bucket.log) > 0 ? aws_s3_bucket.log[0].id : null
}

output "s3_iam_policy_arn" {
  description = "S3 IAM policy ARN"
  value       = aws_iam_policy.s3.arn
}
