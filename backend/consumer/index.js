const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.TABLE_NAME || "Files";

exports.handler = async (event) => {
  console.log("Mensajes recibidos desde SQS:", JSON.stringify(event));

  for (const record of event.Records) {
    const body = JSON.parse(record.body);

    await docClient.send(
      new PutCommand({
        TableName: TABLE_NAME,
        Item: body
      })
    );
  }

  return { statusCode: 200 };
};
