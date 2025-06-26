const { handler } = require("./index");
const AWS = require("aws-sdk");

jest.mock("aws-sdk", () => {
  const publishMock = jest.fn().mockReturnValue({
    promise: jest.fn().mockResolvedValue({})
  });

  const SNS = jest.fn(() => ({ publish: publishMock }));

  const Converter = {
    unmarshall: jest.fn()
  };

  return {
    SNS,
    DynamoDB: {
      Converter
    }
  };
});

const topicArn = "arn:aws:sns:us-east-1:123456789012:MiTopico";
process.env.SNS_TOPIC_ARN = topicArn;

describe("Lambda Filtro (SNS)", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("ignora eventos que no son INSERT", async () => {
    const event = {
      Records: [{ eventName: "MODIFY" }]
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(200);
  });

  it("ignora si el tipo no es 'urgente'", async () => {
    const Converter = require("aws-sdk").DynamoDB.Converter;
    Converter.unmarshall.mockReturnValue({ tipo: "normal" });

    const event = {
      Records: [{
        eventName: "INSERT",
        dynamodb: {
          NewImage: {}
        }
      }]
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(200);

    const snsInstance = new AWS.SNS();
    expect(snsInstance.publish).not.toHaveBeenCalled();
  });

  it("publica a SNS si el tipo es 'urgente'", async () => {
    const Converter = require("aws-sdk").DynamoDB.Converter;
    const mensaje = { tipo: "urgente", mensaje: "¡Atención!" };
    Converter.unmarshall.mockReturnValue(mensaje);

    const event = {
      Records: [{
        eventName: "INSERT",
        dynamodb: {
          NewImage: {}
        }
      }]
    };

    const res = await handler(event);
    expect(res.statusCode).toBe(200);

    const snsInstance = new AWS.SNS();
    expect(snsInstance.publish).toHaveBeenCalledWith({
      Message: JSON.stringify(mensaje),
      TopicArn: topicArn
    });
  });
});
