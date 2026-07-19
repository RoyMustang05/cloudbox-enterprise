variable "lambda_role_arn" {
  type        = string
  description = "ARN del rol IAM que asumirán todas las funciones Lambda"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Nombre de la tabla DynamoDB usada por las funciones"
  default     = "Files"
}

variable "queue_url" {
  type        = string
  description = "URL de la cola SQS documents-queue (Laboratorio 9). La usa la Lambda Productora (createFile)."
  default     = ""
}
