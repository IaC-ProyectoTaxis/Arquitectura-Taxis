resource "aws_kms_key" "s3_encryption_key" {
  description             = "KMS key for S3 default encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "default",
    "Statement": [
      {
        "Sid": "AllowRootAccountFullAccess",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::923789128997:root" 
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}//id de root linea 15

resource "aws_s3_bucket" "bucket" {
  bucket = "taxis-bucket"

  lifecycle_rule {
    id     = "log-expiration-policy"
    status = "Enabled"
    prefix = ""

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_default_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.usuarios.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "usuarios/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.taxis.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "taxis/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.viajes.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "viajes/"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_usuarios,
    aws_lambda_permission.allow_s3,
    aws_lambda_permission.allow_s3_viajes
  ]
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}
