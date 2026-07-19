const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type,Authorization,X-Api-Key",
  "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
};

exports.handler = async (event) => {
  console.log("Evento recibido");
  console.log(event);

  const claims = event.requestContext.authorizer.claims;
  const ownerId = claims.sub;
  const fileId = event.pathParameters.id;

  let body;
  try {
    body = JSON.parse(event.body || "{}");
  } catch (err) {
    return { statusCode: 400, headers: CORS_HEADERS, body: JSON.stringify({ message: "Body inválido" }) };
  }

  // 1. Validar que el registro exista y pertenezca al usuario
  const existing = await docClient.send(
    new GetCommand({ TableName: "Files", Key: { fileId } })
  );

  if (!existing.Item || existing.Item.ownerId !== ownerId) {
    return { statusCode: 403, headers: CORS_HEADERS, body: JSON.stringify({ message: "Forbidden" }) };
  }

  // 2. Actualizar únicamente fileName, category y size
  const updateExpressionParts = [];
  const expressionAttributeNames = {};
  const expressionAttributeValues = {};

  if (body.fileName !== undefined) {
    updateExpressionParts.push("#fileName = :fileName");
    expressionAttributeNames["#fileName"] = "fileName";
    expressionAttributeValues[":fileName"] = body.fileName;
  }
  if (body.category !== undefined) {
    updateExpressionParts.push("#category = :category");
    expressionAttributeNames["#category"] = "category";
    expressionAttributeValues[":category"] = body.category;
  }
  if (body.size !== undefined) {
    updateExpressionParts.push("#size = :size");
    expressionAttributeNames["#size"] = "size";
    expressionAttributeValues[":size"] = Number(body.size);
  }

  if (updateExpressionParts.length === 0) {
    return { statusCode: 400, headers: CORS_HEADERS, body: JSON.stringify({ message: "Nada para actualizar" }) };
  }

  const result = await docClient.send(
    new UpdateCommand({
      TableName: "Files",
      Key: { fileId },
      UpdateExpression: "SET " + updateExpressionParts.join(", "),
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: "ALL_NEW"
    })
  );

  return {
    statusCode: 200,
    headers: CORS_HEADERS,
    body: JSON.stringify(result.Attributes)
  };
};
