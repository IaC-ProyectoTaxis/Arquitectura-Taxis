const { Client } = require("pg");

exports.handler = async (event) => {
  const method = event.httpMethod || "POST";
  const timestamp = new Date().toISOString();

  console.info(
    JSON.stringify({
      level: "INFO",
      event: "HTTP_REQUEST",
      method,
      timestamp,
    })
  );

  // Medición de memoria usada
  const memory = process.memoryUsage();
  console.info(
    JSON.stringify({
      level: "INFO",
      event: "MEMORY_USAGE",
      timestamp,
      memory: {
        rss: memory.rss,
        heapUsed: memory.heapUsed,
        heapTotal: memory.heapTotal,
      },
    })
  );

  const { placa, color, modelo, conductor } = JSON.parse(event.body || "{}");

  if (!placa || !color || !modelo || !conductor) {
    console.warn(
      JSON.stringify({
        level: "WARN",
        event: "MISSING_FIELDS",
        timestamp,
        data: { placa, color, modelo, conductor },
      })
    );
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Faltan datos obligatorios" }),
    };
  }

  const client = new Client({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: 5432,
    ssl: { rejectUnauthorized: false },
  });

  try {
    console.info(
      JSON.stringify({
        level: "INFO",
        event: "DB_CONNECTION_START",
        timestamp,
      })
    );

    await client.connect();

    const query =
      "INSERT INTO taxis (placa, color, modelo, conductor) VALUES ($1, $2, $3, $4)";
    await client.query(query, [placa, color, modelo, conductor]);

    console.info(
      JSON.stringify({
        level: "INFO",
        event: "DB_INSERT_SUCCESS",
        timestamp,
        placa,
      })
    );

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Taxi agregado" }),
    };
  } catch (error) {
    console.error(
      JSON.stringify({
        level: "ERROR",
        event: "DB_INSERT_FAILURE",
        timestamp,
        error: error.message,
      })
    );
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Error al insertar en la BD" }),
    };
  } finally {
    await client.end();
    console.info(
      JSON.stringify({
        level: "INFO",
        event: "DB_CONNECTION_CLOSED",
        timestamp,
      })
    );
  }
};