const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { randomUUID } = require("crypto");

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const HEADERS = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Allow-Methods": "POST,OPTIONS",
};

exports.handler = async (event) => {
  if (event.httpMethod === "OPTIONS") {
    return { statusCode: 200, headers: HEADERS, body: "" };
  }

  try {
    let body;
    try {
      body = JSON.parse(event.body || "{}");
    } catch {
      return {
        statusCode: 400,
        headers: HEADERS,
        body: JSON.stringify({ success: false, error: "Invalid JSON body" }),
      };
    }

    const { message, author } = body;

    if (!message || message.trim() === "") {
      return {
        statusCode: 400,
        headers: HEADERS,
        body: JSON.stringify({ success: false, error: "Message cannot be empty" }),
      };
    }

    if (message.length > 500) {
      return {
        statusCode: 400,
        headers: HEADERS,
        body: JSON.stringify({ success: false, error: "Message too long (max 500 chars)" }),
      };
    }

    const item = {
      messageId: randomUUID(),
      timestamp: new Date().toISOString(),
      message: message.trim(),
      author: (author || "Anonymous").trim().substring(0, 50),
    };

    await docClient.send(
      new PutCommand({
        TableName: process.env.DYNAMODB_TABLE,
        Item: item,
      })
    );

    return {
      statusCode: 201,
      headers: HEADERS,
      body: JSON.stringify({ success: true, item }),
    };
  } catch (error) {
    console.error("Error storing message:", error);
    return {
      statusCode: 500,
      headers: HEADERS,
      body: JSON.stringify({ success: false, error: "Failed to store message" }),
    };
  }
};