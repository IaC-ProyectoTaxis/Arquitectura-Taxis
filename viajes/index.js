const AWS = require("aws-sdk");
const { v4: uuidv4 } = require("uuid");
const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const timestamp = new Date().toISOString();

  const { user_id, placa, fecha, origen, destino, precio } = JSON.parse(event.body || "{}");

  if (!user_id || !placa || !origen || !destino || !precio) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "Faltan datos obligatorios." })
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

  const id = uuidv4(); // ID único para cada viaje

  const params = {
    TableName: "viajes",
    Item: {
      id,
      user_id,
      placa,
      fecha: fecha || timestamp,
      origen,
      destino,
      precio
    }
  };

  try {
    await dynamo.put(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Viaje registrado con éxito." })
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Error al insertar el viaje.", error: error.message })
    };
  }
};