output "s3_base_s3_bucket_id" {
  description = "S3 base S3 bucket ID"
  value       = aws_s3_bucket.base.id
}

output "s3_log_s3_bucket_id" {
  description = "S3 log S3 bucket ID"
  value       = length(aws_s3_bucket.log) > 0 ? aws_s3_bucket.log[0].id : null
}
