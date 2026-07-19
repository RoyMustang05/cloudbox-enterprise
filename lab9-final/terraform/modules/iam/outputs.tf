output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "lambda_role_id" {
  value = aws_iam_role.lambda_role.id
}

output "lambda_role_name" {
  value = aws_iam_role.lambda_role.name
}
