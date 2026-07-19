variable "aws_region" {
  type        = string
  description = "Región de AWS donde se despliega la infraestructura"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Nombre del proyecto, usado como prefijo/tag en los recursos"
  default     = "cloudbox"
}
