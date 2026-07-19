variable "cognito_user_pool_arn" {
  type = string
}

variable "lambda_invoke_arns" {
  type        = map(string)
  description = "Mapa nombre_funcion => invoke_arn"
}

variable "lambda_function_names" {
  type        = map(string)
  description = "Mapa nombre_funcion => function_name"
}
