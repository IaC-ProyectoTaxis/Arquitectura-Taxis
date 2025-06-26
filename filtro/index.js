const AWS = require('aws-sdk');
const sns = new AWS.SNS();

const topicArn = process.env.SNS_TOPIC_ARN;

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    if (record.eventName === "INSERT") {
      const newItem = AWS.DynamoDB.Converter.unmarshall(record.dynamodb.NewImage);

      if (newItem.tipo === "urgente") {
        await sns.publish({
          Message: JSON.stringify(newItem),
          TopicArn: topicArn,
        }).promise();

        console.log("Notificación enviada a SNS:", newItem);
      }
    }
  }

  return { statusCode: 200 };
};
