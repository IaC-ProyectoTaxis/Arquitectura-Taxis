const { Client } = require('pg');

exports.handler = async (event) => {
  const timestamp = new Date().toISOString();

  console.info(JSON.stringify({
    level: "INFO",
    event: "HTTP_REQUEST",
    method: event.httpMethod,
    timestamp
  }));

  const { user_id, placa, fecha, origen, destino, precio } = JSON.parse(event.body || "{}");

  // Validación de datos
  if (!user_id || !placa || !origen || !destino || !precio) {
    console.warn(JSON.stringify({
      level: "WARN",
      event: "MISSING_FIELDS",
      timestamp,
      data: { user_id, placa, origen, destino, precio }
    }));
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Faltan datos obligatorios.' })
    };
  }

  // Uso de memoria
  const memory = process.memoryUsage();
  console.info(JSON.stringify({
    level: "INFO",
    event: "MEMORY_USAGE",
    timestamp,
    memory: {
      heapUsed: memory.heapUsed,
      heapTotal: memory.heapTotal
    }
  }));

  // Conexión a DB
  const client = new Client({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: 5432,
    ssl: { rejectUnauthorized: false }
  });

  try {
    console.info(JSON.stringify({
      level: "INFO",
      event: "DB_CONNECTION_START",
      timestamp
    }));

    await client.connect();

    const query = 'INSERT INTO viajes (user_id, placa, fecha, origen, destino, precio) VALUES ($1, $2, $3, $4, $5, $6)';
    await client.query(query, [user_id, placa, fecha, origen, destino, precio]);

    console.info(JSON.stringify({
      level: "INFO",
      event: "DB_INSERT_SUCCESS",
      timestamp,
      user_id,
      placa,
      destino
    }));

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Datos insertados correctamente.' })
    };
  } catch (error) {
    console.error(JSON.stringify({
      level: "ERROR",
      event: "DB_INSERT_FAILURE",
      timestamp,
      error: error.message
    }));
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Hubo un error al insertar los datos.', error: error.message })
    };
  } finally {
    await client.end();
    console.info(JSON.stringify({
      level: "INFO",
      event: "DB_CONNECTION_CLOSED",
      timestamp
    }));
  }
};