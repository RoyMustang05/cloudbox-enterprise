const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

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

  const result = await docClient.send(
    new ScanCommand({
      TableName: "Files"
    })
  );

  const files = (result.Items || []).filter(
    (item) => item.ownerId === ownerId && item.status === "ACTIVE"
  );

  return {
    statusCode: 200,
    headers: CORS_HEADERS,
    body: JSON.stringify(files)
  };
};
