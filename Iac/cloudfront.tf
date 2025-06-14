resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "cloudfront-s3-oac"
  description                       = "Access control for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "s3-site-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = false
  web_acl_id = aws_wafv2_web_acl.api_waf_acl.id
  default_root_object = "index.html"
  logging_config {
    bucket = "mylogs.s3.amazonaws.com"
  }

  default_cache_behavior {
    target_origin_id       = "s3-site-origin"
    viewer_protocol_policy = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors_policy.id

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = ["US", "CA", "GB"]
    }
  }

  tags = {
    Name = "cloudfront-cdn"
  }
}


resource "aws_cloudfront_response_headers_policy" "cors_policy" {
  name = "AllowCORSCloudFront"

  cors_config {
    access_control_allow_credentials = true

    access_control_allow_headers {
      items = ["Content-Type", "Authorization"]
    }

    access_control_allow_methods {
      items = ["GET", "POST", "OPTIONS"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    origin_override = true
  }
}
