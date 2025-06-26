const { handler } = require("./index");
const AWS = require("aws-sdk");

jest.mock("aws-sdk", () => {
  const mockPut = jest.fn().mockReturnValue({
    promise: jest.fn().mockResolvedValue({}),
  });
  return {
    DynamoDB: {
      DocumentClient: jest.fn(() => ({
        put: mockPut,
      })),
    },
  };
});

describe("Lambda Taxis", () => {
  it("retorna 400 si faltan campos obligatorios", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({ placa: "XYZ123" }) // faltan campos
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(400);
    expect(JSON.parse(res.body)).toHaveProperty("error", "Faltan datos obligatorios");
  });

  it("retorna 200 si todos los campos están presentes", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({
        placa: "XYZ123",
        color: "Rojo",
        modelo: "Toyota",
        conductor: "Juan Perez"
      })
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body)).toHaveProperty("message", "Taxi agregado");
  });
});
