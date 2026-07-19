output "invoke_url" {
  value = aws_api_gateway_stage.dev.invoke_url
}

output "api_key_id" {
  value = aws_api_gateway_api_key.files_api_key.id
}

output "api_key_value" {
  value     = aws_api_gateway_api_key.files_api_key.value
  sensitive = true
}
