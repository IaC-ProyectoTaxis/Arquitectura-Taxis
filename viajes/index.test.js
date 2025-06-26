const { handler } = require("./index");

describe("Lambda Viajes (Integración con DynamoDB AWS)", () => {
  test("✅ debería insertar viaje válido y retornar 200", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({
        user_id: "user123",
        placa: "XYZ123",
        origen: "Ciudad A",
        destino: "Ciudad B",
        precio: 50.75
      })
    };

    const response = await handler(event);
    expect(response.statusCode).toBe(200);
    expect(JSON.parse(response.body)).toHaveProperty("message", "Viaje registrado con éxito.");
  });

  test("⚠️ debería retornar 400 si faltan datos requeridos", async () => {
    const event = {
      httpMethod: "POST",
      body: JSON.stringify({
        user_id: "user123",
        placa: "XYZ123"
        // faltan origen, destino y precio
      })
    };

    const response = await handler(event);
    expect(response.statusCode).toBe(400);
    expect(JSON.parse(response.body)).toHaveProperty("message", "Faltan datos obligatorios.");
  });
});
