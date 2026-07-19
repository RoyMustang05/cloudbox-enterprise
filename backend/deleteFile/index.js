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

  // Verificar propiedad antes de "eliminar"
  const existing = await docClient.send(
    new GetCommand({ TableName: "Files", Key: { fileId } })
  );

  if (!existing.Item || existing.Item.ownerId !== ownerId) {
    return { statusCode: 403, headers: CORS_HEADERS, body: JSON.stringify({ message: "Forbidden" }) };
  }

  // Eliminación lógica: NO se borra el registro, se marca como DELETED
  const result = await docClient.send(
    new UpdateCommand({
      TableName: "Files",
      Key: { fileId },
      UpdateExpression: "SET #status = :status",
      ExpressionAttributeNames: { "#status": "status" },
      ExpressionAttributeValues: { ":status": "DELETED" },
      ReturnValues: "ALL_NEW"
    })
  );

  return {
    statusCode: 200,
    headers: CORS_HEADERS,
    body: JSON.stringify(result.Attributes)
  };
};
