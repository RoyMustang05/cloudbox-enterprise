# ---- Outputs heredados del Laboratorio 7 (backend) ----
output "api_url" {
  value = module.apigateway.invoke_url
}

output "api_key_value" {
  value     = module.apigateway.api_key_value
  sensitive = true
}

output "user_pool_id" {
  value = module.cognito.user_pool_id
}

output "app_client_id" {
  value = module.cognito.client_id
}

output "region" {
  value = var.aws_region
}

output "dynamodb_table" {
  value = module.dynamodb.table_name
}

# ---- Outputs heredados del Laboratorio 8 (frontend) ----
output "frontend_url" {
  value = module.frontend.frontend_url
}

output "bucket_name" {
  value = module.frontend.bucket_name
}

output "cloudfront_domain" {
  value = module.frontend.cloudfront_domain
}

# ---- Outputs nuevos del Laboratorio 9 (SQS) ----
output "documents_queue_url" {
  value = aws_sqs_queue.documents_queue.id
}

output "documents_queue_arn" {
  value = aws_sqs_queue.documents_queue.arn
}

output "documents_dlq_url" {
  value = aws_sqs_queue.documents_dlq.id
}
