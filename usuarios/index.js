const AWS = require("aws-sdk");
const { v4: uuidv4 } = require("uuid");
const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const timestamp = new Date().toISOString();
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
  };

  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: "CORS preflight passed" }),
    };
  }

  const { nombre, correo, contraseña } = JSON.parse(event.body || "{}");

  if (!nombre || !correo || !contraseña) {
    return {
      statusCode: 400,
      headers,
      body: JSON.stringify({ message: "Faltan datos obligatorios." }),
    };
  }

  const memory = process.memoryUsage();
  console.info(JSON.stringify({
    level: "INFO",
    event: "MEMORY_USAGE",
    timestamp,
    memory: {
      heapUsed: memory.heapUsed,
      heapTotal: memory.heapTotal,
    }
  }));

  const id = uuidv4(); // Generar ID único
  const group = event.requestContext?.authorizer?.claims?.["cognito:groups"] || "unknown";

  if (group !== "admin" && group !== "user") {
    return {
      statusCode: 403,
      headers,
      body: JSON.stringify({ message: "No autorizado" }),
    };
  }

  const params = {
    TableName: "usuarios",
    Item: {
      id,
      nombre,
      correo,
      contraseña
    }
  };

  try {
    await dynamo.put(params).promise();
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: "Datos insertados correctamente." }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ message: "Error al insertar.", error: error.message }),
    };
  }
};