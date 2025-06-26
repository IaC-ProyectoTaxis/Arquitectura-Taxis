const { handler } = require("./index");

describe("Lambda Usuarios (Integración con DynamoDB AWS)", () => {
  test("✅ debería insertar usuario válido y retornar 200", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({
        nombre: "Carlos Pérez",
        correo: "carlos@example.com",
        contraseña: "segura123"
      }),
      requestContext: {
        authorizer: {
          claims: {
            "cognito:groups": "admin"
          }
        }
      }
    };

    const response = await handler(event);
    expect(response.statusCode).toBe(200);
    expect(JSON.parse(response.body)).toHaveProperty("message", "Datos insertados correctamente.");
  });

  test("⚠️ debería retornar 400 si faltan datos", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({ nombre: "Ana" }), // faltan campos
      requestContext: {
        authorizer: {
          claims: {
            "cognito:groups": "admin"
          }
        }
      }
    };

    const response = await handler(event);
    expect(response.statusCode).toBe(400);
    expect(JSON.parse(response.body)).toHaveProperty("message", "Faltan datos obligatorios.");
  });

  test("🚫 debería retornar 403 si el grupo no es válido", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({
        nombre: "Luis",
        correo: "luis@example.com",
        contraseña: "123456"
      }),
      requestContext: {
        authorizer: {
          claims: {
            "cognito:groups": "invitado" // grupo inválido
          }
        }
      }
    };

    const response = await handler(event);
    expect(response.statusCode).toBe(403);
    expect(JSON.parse(response.body)).toHaveProperty("message", "No autorizado");
  });

  test("🔁 debería retornar 200 para peticiones OPTIONS (CORS)", async () => {
    const event = {
      httpMethod: "OPTIONS"
    };

    const response = await handler(event);
    expect(response.statusCode).toBe(200);
    expect(JSON.parse(response.body)).toHaveProperty("message", "CORS preflight passed");
  });
});
