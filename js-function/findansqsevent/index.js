console.log('Loading function');

const { PutObjectCommand, S3Client } = require("@aws-sdk/client-s3");

// Get the name of the bucket and the prefix to use
const { bucket, prefix } = process.env;

console.log(`Bucket: ${bucket}; Prefix: ${prefix}`);

const client = new S3Client({});

exports.handler = async (event) => {
    //console.log('Received event:', JSON.stringify(event, null, 2));
    for (const { messageId, body } of event.Records) {
        console.log('SQS message %s: %j', messageId, body);
        
        const command = new PutObjectCommand({
            Body: body,
            Bucket: bucket,
            Key: prefix.endsWith('/') ?
                `${prefix}${messageId}.json` : 
                `${prefix}/${messageId}.json`
        });
        
        const response = await client.send(command);
        console.log('S3 response: ' + JSON.stringify(response));
    }
    return `Successfully processed ${event.Records.length} messages.`;
};
