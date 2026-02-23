const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const docClient = DynamoDBDocumentClient.from(client);

const HEADERS = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Allow-Methods": "GET,OPTIONS",
};

exports.handler = async (event) => {
  // Handle preflight
  if (event.httpMethod === "OPTIONS") {
    return { statusCode: 200, headers: HEADERS, body: "" };
  }

  try {
    const command = new ScanCommand({
      TableName: process.env.DYNAMODB_TABLE,
      Limit: 50,
    });

    const response = await docClient.send(command);

    // Sort by timestamp descending (newest first)
    const items = (response.Items || []).sort(
      (a, b) => new Date(b.timestamp) - new Date(a.timestamp)
    );

    return {
      statusCode: 200,
      headers: HEADERS,
      body: JSON.stringify({
        success: true,
        messages: items,
        count: items.length,
      }),
    };
  } catch (error) {
    console.error("Error fetching messages:", error);
    return {
      statusCode: 500,
      headers: HEADERS,
      body: JSON.stringify({
        success: false,
        error: "Failed to retrieve messages",
      }),
    };
  }
};