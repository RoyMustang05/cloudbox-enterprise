# ---------- Sufijo único por equipo/despliegue ----------
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ---------- Generación automática de .env.production ----------
resource "local_file" "env" {
  filename = "${path.root}/../frontend/.env.production"
  content  = <<EOF
VITE_API_URL=${var.api_url}
VITE_USER_POOL_ID=${var.user_pool_id}
VITE_CLIENT_ID=${var.client_id}
VITE_REGION=${var.region}
VITE_API_KEY=${var.api_key}
EOF
}

# ---------- Build automático del frontend React ----------
resource "null_resource" "react_build" {
  depends_on = [local_file.env]

  triggers = {
    env_hash = local_file.env.content
  }

  provisioner "local-exec" {
    working_dir = "${path.root}/../frontend"
    # Sin "interpreter" explícito para que funcione tanto en Windows (cmd)
    # como en Linux/GitHub Actions (sh); "&&" es compatible con ambos.
    command = "npm install && npm run build"
  }
}

# ---------- Bucket S3 ----------
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend-${random_string.suffix.result}"

  tags = {
    Project     = var.project_name
    Environment = "lab"
    ManagedBy   = "Terraform"
    Owner       = "Cloud Team"
  }
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  depends_on = [
    aws_s3_bucket_public_access_block.frontend
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.frontend.arn}/*"]
      }
    ]
  })
}

# ---------- Publicación de archivos ----------
resource "aws_s3_object" "index" {
  depends_on = [null_resource.react_build]

  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${path.root}/../frontend/dist/index.html"
  etag         = filemd5("${path.root}/../frontend/dist/index.html")
  content_type = "text/html"
  cache_control = "no-cache, no-store, must-revalidate"
}

resource "aws_s3_object" "assets" {
  for_each = fileset("${path.root}/../frontend/dist/assets", "**")

  depends_on = [null_resource.react_build]

  bucket = aws_s3_bucket.frontend.id
  key    = "assets/${each.value}"
  source = "${path.root}/../frontend/dist/assets/${each.value}"
  etag   = filemd5("${path.root}/../frontend/dist/assets/${each.value}")
  content_type = endswith(each.value, ".js") ? "application/javascript" : endswith(each.value, ".css") ? "text/css" : endswith(each.value, ".svg") ? "image/svg+xml" : endswith(each.value, ".png") ? "image/png" : endswith(each.value, ".jpg") ? "image/jpeg" : endswith(each.value, ".jpeg") ? "image/jpeg" : endswith(each.value, ".webp") ? "image/webp" : "application/octet-stream"
  cache_control = "no-cache, no-store, must-revalidate"
}

# ---------- CloudFront ----------
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket_website_configuration.frontend.website_endpoint
    origin_id   = "frontend-origin"

    custom_origin_config {
      http_port               = 80
      https_port               = 443
      origin_protocol_policy  = "http-only"
      origin_ssl_protocols    = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods          = ["GET", "HEAD"]
    target_origin_id        = "frontend-origin"
    viewer_protocol_policy  = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project = var.project_name
  }
}

# ---------- Invalidación automática de caché en cada despliegue ----------
resource "null_resource" "cloudfront_invalidation" {
  depends_on = [
    aws_s3_object.index,
    aws_s3_object.assets
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.frontend.id} --paths /*"
  }
}
