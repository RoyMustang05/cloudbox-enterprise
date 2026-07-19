variable "lambda_function_names" {
  type        = map(string)
  description = "Mapa nombre_funcion => function_name, para crear un log group por cada una"
}
