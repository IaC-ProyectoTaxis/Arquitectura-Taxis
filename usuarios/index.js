const { Client } = require("pg");

exports.handler = async (event) => {
  const timestamp = new Date().toISOString();
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
  };

  if (event.httpMethod === "OPTIONS") {
    console.info(
      JSON.stringify({
        level: "INFO",
        event: "CORS_PRE_FLIGHT",
        timestamp,
      })
    );
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: "CORS preflight passed" }),
    };
  }

  console.info(
    JSON.stringify({
      level: "INFO",
      event: "HTTP_REQUEST",
      method: event.httpMethod,
      timestamp,
    })
  );

  const { id, nombre, correo, contraseña } = JSON.parse(event.body || "{}");

  if (!nombre || !correo || !contraseña) {
    console.warn(
      JSON.stringify({
        level: "WARN",
        event: "MISSING_FIELDS",
        timestamp,
        data: { nombre, correo, contraseña },
      })
    );
    return {
      statusCode: 400,
      headers,
      body: JSON.stringify({ message: "Faltan datos obligatorios." }),
    };
  }

  // Medición de memoria usada
  const memory = process.memoryUsage();
  console.info(
    JSON.stringify({
      level: "INFO",
      event: "MEMORY_USAGE",
      timestamp,
      memory: {
        heapUsed: memory.heapUsed,
        heapTotal: memory.heapTotal,
      },
    })
  );

  const client = new Client({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: 5432,
    ssl: { rejectUnauthorized: false },
  });

  const group =
    event.requestContext?.authorizer?.claims?.["cognito:groups"] || "unknown";

  console.info(
    JSON.stringify({
      level: "INFO",
      event: "AUTHORIZATION_GROUP",
      timestamp,
      group,
    })
  );

  if (group !== "admin" && group !== "user") {
    console.error(
      JSON.stringify({
        level: "ERROR",
        event: "UNAUTHORIZED_ACCESS",
        timestamp,
        group,
      })
    );
    return {
      statusCode: 403,
      headers,
      body: JSON.stringify({ message: "No autorizado" }),
    };
  }

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
      "INSERT INTO usuarios (id, nombre, correo, contraseña) VALUES ($1, $2, $3, $4)";
    await client.query(query, [id, nombre, correo, contraseña]);

    console.info(
      JSON.stringify({
        level: "INFO",
        event: "DB_INSERT_SUCCESS",
        timestamp,
        id,
        correo,
      })
    );

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: "Datos insertados correctamente." }),
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
      headers,
      body: JSON.stringify({
        message: "Hubo un error al insertar los datos.",
        error: error.message,
      }),
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
