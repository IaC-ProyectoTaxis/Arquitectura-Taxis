const { handler } = require("./index");
const AWS = require("aws-sdk");
const { v4: uuidv4 } = require("uuid");

jest.mock("aws-sdk", () => {
  const putMock = jest.fn().mockReturnValue({
    promise: jest.fn().mockResolvedValue({}),
  });

  return {
    DynamoDB: {
      DocumentClient: jest.fn(() => ({
        put: putMock,
      })),
    },
  };
});

jest.mock("uuid", () => ({
  v4: jest.fn(() => "mocked-uuid"),
}));

describe("Lambda Usuarios", () => {
  it("responde a la preflight CORS (OPTIONS)", async () => {
    const event = {
      httpMethod: "OPTIONS",
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body)).toHaveProperty("message", "CORS preflight passed");
  });

  it("retorna 400 si faltan campos obligatorios", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({
        nombre: "Ana",
        // falta correo y contraseña
      }),
      requestContext: {
        authorizer: {
          claims: {
            "cognito:groups": "admin"
          }
        }
      }
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(400);
    expect(JSON.parse(res.body)).toHaveProperty("message", "Faltan datos obligatorios.");
  });

  it("retorna 403 si el grupo no es válido", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({
        nombre: "Ana",
        correo: "ana@example.com",
        contraseña: "secreta"
      }),
      requestContext: {
        authorizer: {
          claims: {
            "cognito:groups": "invitado"
          }
        }
      }
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(403);
    expect(JSON.parse(res.body)).toHaveProperty("message", "No autorizado");
  });

  it("retorna 200 si los datos son válidos y el grupo es válido", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({
        nombre: "Ana",
        correo: "ana@example.com",
        contraseña: "secreta"
      }),
      requestContext: {
        authorizer: {
          claims: {
            "cognito:groups": "admin"
          }
        }
      }
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body)).toHaveProperty("message", "Datos insertados correctamente.");
  });
});
