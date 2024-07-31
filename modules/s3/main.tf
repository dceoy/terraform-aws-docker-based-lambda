resource "aws_s3_bucket" "io" {
  bucket        = local.io_s3_bucket_name
  force_destroy = var.s3_force_destroy
  tags = {
    Name       = local.io_s3_bucket_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

# trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "log" {
  count         = var.enable_s3_server_access_logging ? 1 : 0
  bucket        = local.log_s3_bucket_name
  force_destroy = var.s3_force_destroy
  tags = {
    Name       = local.log_s3_bucket_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_s3_bucket_logging" "io" {
  count         = length(aws_s3_bucket.log) > 0 ? 1 : 0
  bucket        = aws_s3_bucket.io.id
  target_bucket = aws_s3_bucket.log[count.index].id
  target_prefix = "${aws_s3_bucket.io.id}/"
}

resource "aws_s3_bucket_public_access_block" "io" {
  bucket                  = aws_s3_bucket.io.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "log" {
  count                   = length(aws_s3_bucket.log) > 0 ? 1 : 0
  bucket                  = aws_s3_bucket.log[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "io" {
  bucket = aws_s3_bucket.io.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  count  = length(aws_s3_bucket.log) > 0 ? 1 : 0
  bucket = aws_s3_bucket.log[count.index].id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "io" {
  bucket = aws_s3_bucket.io.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "log" {
  count  = length(aws_s3_bucket.log) > 0 ? 1 : 0
  bucket = aws_s3_bucket.log[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "io" {
  bucket = aws_s3_bucket.io.id
  rule {
    status = "Enabled"
    id     = "Move-to-Intelligent-Tiering-after-0day"
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_expiration {
      noncurrent_days = var.s3_noncurrent_version_expiration_days
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_abort_incomplete_multipart_upload_days
    }
    expiration {
      days                         = var.s3_expiration_days
      expired_object_delete_marker = var.s3_expired_object_delete_marker
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log" {
  count  = length(aws_s3_bucket.log) > 0 ? 1 : 0
  bucket = aws_s3_bucket.log[count.index].id
  rule {
    status = "Enabled"
    id     = "Move-to-Intelligent-Tiering-after-0day"
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
    noncurrent_version_expiration {
      noncurrent_days = var.s3_noncurrent_version_expiration_days
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_abort_incomplete_multipart_upload_days
    }
    expiration {
      days                         = var.s3_expiration_days
      expired_object_delete_marker = var.s3_expired_object_delete_marker
    }
  }
}

resource "aws_s3_bucket_policy" "log" {
  count  = length(aws_s3_bucket.log) > 0 ? 1 : 0
  bucket = aws_s3_bucket.log[count.index].id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${aws_s3_bucket.log[count.index].id}-policy"
    Statement = [
      {
        Sid    = "S3PutS3ServerAccessLogs"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.log[count.index].arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${var.system_name}-${var.env_type}-*"
          }
        }
      }
    ]
  })
}

# trivy:ignore:AVD-AWS-0057
resource "aws_iam_policy" "s3" {
  name        = "${var.system_name}-${var.env_type}-s3-iam-policy"
  description = "S3 IAM policy"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "AllowS3BucketAccess"
          Effect = "Allow"
          Action = [
            "s3:Describe*",
            "s3:Get*",
            "s3:List*",
            "s3-object-lambda:Get*",
            "s3-object-lambda:List*"
          ]
          Resource = [
            aws_s3_bucket.io.arn,
            "${aws_s3_bucket.io.arn}/*"
          ]
        }
      ],
      (
        var.kms_key_arn != null ? [
          {
            Sid    = "AllowKMSAccess"
            Effect = "Allow"
            Action = [
              "kms:Decrypt",
              "kms:GenerateDataKey"
            ]
            Resource = [var.kms_key_arn]
          }
        ] : []
      )
    )
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-s3-iam-policy"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
