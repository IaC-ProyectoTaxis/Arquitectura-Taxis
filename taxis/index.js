const AWS = require("aws-sdk");

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const method = event.httpMethod  "POST";
  const timestamp = new Date().toISOString();

  console.info(JSON.stringify({
    level: "INFO",
    event: "HTTP_REQUEST",
    method,
    timestamp,
  }));

  const memory = process.memoryUsage();
  console.info(JSON.stringify({
    level: "INFO",
    event: "MEMORY_USAGE",
    timestamp,
    memory: {
      rss: memory.rss,
      heapUsed: memory.heapUsed,
      heapTotal: memory.heapTotal,
    },
  }));

  const { placa, color, modelo, conductor } = JSON.parse(event.body  "{}");

  if (!placa  !color  !modelo || !conductor) {
    console.warn(JSON.stringify({
      level: "WARN",
      event: "MISSING_FIELDS",
      timestamp,
      data: { placa, color, modelo, conductor },
    }));
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Faltan datos obligatorios" }),
    };
  }

  const params = {
    TableName: "taxis",
    Item: {
      placa,
      color,
      modelo,
      conductor,
      createdAt: timestamp,
    },
  };

  console.info(JSON.stringify({
  level: "INFO",
  event: "DYNAMODB_PUT_START",
  timestamp,
  params,
  }));

  try {
    await dynamodb.put(params).promise();

    console.info(JSON.stringify({
      level: "INFO",
      event: "DYNAMODB_INSERT_SUCCESS",
      timestamp,
      placa,
    }));

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Taxi agregado" }),
    };
  } catch (error) {
    console.error(JSON.stringify({
      level: "ERROR",
      event: "DYNAMODB_INSERT_FAILURE",
      timestamp,
      error: error.message,
    }));

    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Error al insertar en DynamoDB" }),
    };
  }
};