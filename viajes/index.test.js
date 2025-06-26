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

describe("Lambda Viajes", () => {
  it("retorna 400 si faltan campos obligatorios", async () => {
    const event = {
      body: JSON.stringify({
        user_id: "user1",
        // faltan placa, origen, destino, precio
      })
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(400);
    expect(JSON.parse(res.body)).toHaveProperty("message", "Faltan datos obligatorios.");
  });

  it("retorna 200 si todos los campos están presentes", async () => {
    const event = {
      body: JSON.stringify({
        user_id: "user1",
        placa: "XYZ123",
        origen: "Punto A",
        destino: "Punto B",
        precio: 10.5,
        fecha: "2025-06-26T00:00:00Z"
      })
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body)).toHaveProperty("message", "Viaje registrado con éxito.");
  });
});