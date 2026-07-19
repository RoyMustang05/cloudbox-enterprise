const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const { v4: uuidv4 } = require("uuid");

const sqs = new SQSClient({});
const QUEUE_URL = process.env.QUEUE_URL;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type,Authorization,X-Api-Key",
  "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
};

function badRequest(message) {
  return {
    statusCode: 400,
    headers: CORS_HEADERS,
    body: JSON.stringify({ message })
  };
}

// LABORATORIO 9 - PARTE 2
// Lambda Productora: ya no escribe directo en DynamoDB (PutItem).
// Ahora publica el documento en Amazon SQS (SendMessage) y la
// Lambda Consumidora es la que finalmente lo guarda en la tabla.
exports.handler = async (event) => {
  console.log("Evento recibido");
  console.log(event);

  let body;
  try {
    body = JSON.parse(event.body || "{}");
  } catch (err) {
    return badRequest("Body inválido, se esperaba JSON");
  }

  const claims = event.requestContext.authorizer.claims;
  const ownerId = claims.sub;

  // Validaciones obligatorias
  if (!body.fileName || body.fileName.trim() === "") {
    return badRequest("fileName es obligatorio y no puede estar vacío");
  }
  if (body.size === undefined || body.size === null || Number(body.size) < 0) {
    return badRequest("size debe ser un número mayor o igual a 0");
  }
  if (!body.category || body.category.trim() === "") {
    return badRequest("category es obligatorio y no puede estar vacío");
  }

  const file = {
    fileId: uuidv4(),
    ownerId: ownerId, // se ignora cualquier ownerId enviado en el body
    fileName: body.fileName,
    category: body.category,
    size: Number(body.size),
    status: "ACTIVE",
    uploadDate: new Date().toISOString()
  };

  await sqs.send(
    new SendMessageCommand({
      QueueUrl: QUEUE_URL,
      MessageBody: JSON.stringify(file)
    })
  );

  return {
    statusCode: 201,
    headers: CORS_HEADERS,
    body: JSON.stringify({
      message: "Documento encolado correctamente",
      file
    })
  };
};
