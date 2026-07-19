import os
import re

# 1. Update Lambdas
lambda_dirs = ["createFile", "getFiles", "getFileById", "updateFile", "deleteFile"]
for d in lambda_dirs:
    p = f"backend/{d}/index.js"
    with open(p, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Simple regex to inject CORS headers into returned objects
    if "Access-Control-Allow-Origin" not in content:
        content = re.sub(
            r"(statusCode:\s*\d+,)",
            r"\1\n    headers: {\n      \"Access-Control-Allow-Origin\": \"*\",\n      \"Access-Control-Allow-Headers\": \"*\",\n      \"Access-Control-Allow-Methods\": \"*\"\n    },",
            content
        )
        with open(p, "w", encoding="utf-8") as f:
            f.write(content)

# 2. Update frontend variables.tf
v_tf = "terraform/modules/frontend/variables.tf"
with open(v_tf, "r", encoding="utf-8") as f:
    v_content = f.read()
if "variable \"api_key\"" not in v_content:
    with open(v_tf, "a", encoding="utf-8") as f:
        f.write("\nvariable \"api_key\" {}\n")

# 3. Update frontend main.tf env file
m_tf = "terraform/modules/frontend/main.tf"
with open(m_tf, "r", encoding="utf-8") as f:
    m_content = f.read()
if "VITE_API_KEY=" not in m_content:
    m_content = m_content.replace(
        "VITE_REGION=${var.region}\nEOF",
        "VITE_REGION=${var.region}\nVITE_API_KEY=${var.api_key}\nEOF"
    )
    with open(m_tf, "w", encoding="utf-8") as f:
        f.write(m_content)

# 4. Update terraform/main.tf
main_tf = "terraform/main.tf"
with open(main_tf, "r", encoding="utf-8") as f:
    main_content = f.read()
if "api_key" not in main_content:
    main_content = main_content.replace(
        "client_id    = module.cognito.client_id\n}",
        "client_id    = module.cognito.client_id\n  api_key      = module.apigateway.api_key_value\n}"
    )
    with open(main_tf, "w", encoding="utf-8") as f:
        f.write(main_content)

# 5. Update api.js
api_js = "frontend/src/services/api.js"
with open(api_js, "r", encoding="utf-8") as f:
    api_content = f.read()
if "x-api-key" not in api_content:
    api_content = api_content.replace(
        "return config;\n});",
        "  const apiKey = import.meta.env.VITE_API_KEY;\n  if (apiKey) {\n    config.headers[\"x-api-key\"] = apiKey;\n  }\n  return config;\n});"
    )
    with open(api_js, "w", encoding="utf-8") as f:
        f.write(api_content)

print("Patch applied successfully.")
