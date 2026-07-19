# CloudBox Enterprise

Proyecto unificado para Desarrollo en la Nube. Combina:

- **Laboratorio 7**: backend serverless (API Gateway, Lambda, DynamoDB, Cognito, IAM, CloudWatch).
- **Laboratorio 8**: frontend (React + S3 + CloudFront).
- **Laboratorio 9**: arquitectura Event-Driven con Amazon SQS (Lambda Productora → SQS → Lambda Consumidora → DynamoDB).
- **Laboratorio 10**: backend remoto de Terraform (S3 + DynamoDB) y pipeline CI/CD con GitHub Actions.

## Estructura

```
cloudbox-enterprise/
├── backend/                     Código fuente de las Lambdas (Node.js)
│   ├── createFile/              Lambda Productora (envía a SQS)
│   ├── getFiles/
│   ├── getFileById/
│   ├── updateFile/
│   ├── deleteFile/
│   └── consumer/                Lambda Consumidora (SQS -> DynamoDB)
├── frontend/                    Código fuente del frontend (React + Vite)
├── terraform/                   Todo el código de infraestructura
│   ├── main.tf, variables.tf, outputs.tf, providers.tf, terraform.tfvars
│   ├── sqs.tf                   Laboratorio 9
│   ├── lambda-consumer.tf       Laboratorio 9
│   ├── backend-resources.tf     Laboratorio 10
│   ├── backend.tf.step9         Laboratorio 10 (renombrar a backend.tf en el Paso 9)
│   └── modules/                 dynamodb, cognito, iam, lambda, apigateway, cloudwatch, frontend
└── .github/workflows/terraform.yml   Laboratorio 10
```

Todos los comandos `terraform` se ejecutan **dentro de la carpeta `terraform/`**, nunca en la raíz del repositorio.

## Requisitos previos

- Terraform >= 1.5
- Node.js 18+ y npm (para empaquetar Lambdas y compilar el frontend)
- AWS CLI configurado (`aws configure`) con permisos suficientes
- Cuenta de GitHub

## Notas importantes

- El bucket `cloudbox-terraform-state-XXXXXXXX` debe reemplazarse por un nombre único (carnet/iniciales del equipo) en **dos archivos**: `backend-resources.tf` y `backend.tf.step9`.
- El módulo `frontend` ya no requiere copiar valores manualmente: toma `api_url`, `user_pool_id` y `client_id` directamente de los outputs de los módulos `apigateway` y `cognito`.
- Los `local-exec` de compilación del frontend se ajustaron para funcionar tanto en Windows como en GitHub Actions (Linux), sin depender de PowerShell.
