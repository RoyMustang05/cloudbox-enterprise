output "function_names" {
  value = { for k, f in aws_lambda_function.functions : k => f.function_name }
}

output "function_arns" {
  value = { for k, f in aws_lambda_function.functions : k => f.arn }
}

output "invoke_arns" {
  value = { for k, f in aws_lambda_function.functions : k => f.invoke_arn }
}

# Se mantiene por compatibilidad con el nombre usado en el enunciado original
output "create_file_lambda_arn" {
  value = aws_lambda_function.functions["createFile"].arn
}
