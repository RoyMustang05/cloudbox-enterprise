# =========================================================
# LABORATORIO 10 - PARTE 2
# Recursos para el backend remoto de Terraform (estado + locking)
#
# IMPORTANTE: reemplace XXXXXXXX por un identificador único
# (carnet o iniciales del equipo) porque el nombre del bucket
# debe ser único a nivel mundial en S3.
# =========================================================

resource "aws_s3_bucket" "terraform_backend" {
  bucket = "cloudbox-terraform-state-20245160"
}

resource "aws_s3_bucket_versioning" "terraform_backend_versioning" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_backend_encryption" {
  bucket = aws_s3_bucket.terraform_backend.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
