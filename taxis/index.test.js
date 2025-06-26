const { handler } = require("./index");

describe("Lambda Taxis (Integración con DynamoDB AWS)", () => {
  test("debería insertar taxi válido y retornar 200", async () => {
    const taxi = {
      placa: "XYZ123",
      color: "Rojo",
      modelo: "Toyota",
      conductor: "Juan Pérez"
    };

    const event = {
      httpMethod: "POST",
      body: JSON.stringify(taxi),
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(200);
    expect(JSON.parse(response.body)).toHaveProperty("message", "Taxi agregado");
  });

  test("debería retornar 400 si faltan campos", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({ placa: "XYZ123" }), 
    };

    const response = await handler(event);

    expect(response.statusCode).toBe(400);
    expect(JSON.parse(response.body)).toHaveProperty("error", "Faltan datos obligatorios");
  });
});
