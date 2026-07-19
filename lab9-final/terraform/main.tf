# =========================================================
# CloudBox Enterprise - Proyecto Terraform unificado
# Base: Laboratorio 7 (backend serverless) + Laboratorio 8 (frontend)
# =========================================================

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "cognito" {
  source = "./modules/cognito"
}

module "iam" {
  source = "./modules/iam"
}

module "lambda" {
  source              = "./modules/lambda"
  lambda_role_arn     = module.iam.lambda_role_arn
  dynamodb_table_name = module.dynamodb.table_name
  queue_url           = aws_sqs_queue.documents_queue.id
}

module "apigateway" {
  source                = "./modules/apigateway"
  cognito_user_pool_arn = module.cognito.user_pool_arn
  lambda_invoke_arns    = module.lambda.invoke_arns
  lambda_function_names = module.lambda.function_names
}

module "cloudwatch" {
  source                = "./modules/cloudwatch"
  lambda_function_names = module.lambda.function_names
}

# El módulo frontend ya no depende de valores copiados manualmente
# (Laboratorio 8 los pedía por tfvars); ahora se conectan directamente
# a los outputs de los módulos del backend.
module "frontend" {
  source       = "./modules/frontend"
  project_name = var.project_name
  region       = var.aws_region
  api_url      = module.apigateway.invoke_url
  user_pool_id = module.cognito.user_pool_id
  client_id    = module.cognito.client_id
  api_key      = module.apigateway.api_key_value
}
