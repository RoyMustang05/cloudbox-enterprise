resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = var.lambda_function_names
  name              = "/aws/lambda/${each.value}"
  retention_in_days = 14
}
