import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { Code, Function, Runtime } from 'aws-cdk-lib/aws-lambda';
import { SqsEventSource } from 'aws-cdk-lib/aws-lambda-event-sources';
import { Topic } from 'aws-cdk-lib/aws-sns';
import { SqsSubscription } from 'aws-cdk-lib/aws-sns-subscriptions';
import { Queue } from 'aws-cdk-lib/aws-sqs';
import { Bucket, BucketAccessControl } from 'aws-cdk-lib/aws-s3';
import * as path from 'path';

export class FindAnSqsEventStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create a Bucket to store the messages in
    const bucket = new Bucket(this, 'findansqsevent-s3',
    {
      accessControl: BucketAccessControl.PRIVATE      
    });

    // Create a lambda to read events from an SQS and write them to the bucket
    const lambda = new Function(this, 'findansqsevent-lambda',
    {
      runtime: Runtime.NODEJS_18_X,
      code: Code.fromAsset(path.join(__dirname, '/../js-function/findansqsevent')),
      handler: "index.handler",
      environment: {
        bucket: bucket.bucketName,
        prefix: "outputFolder/"
      }
    });

    // Grant the lambda put access to the bucket
    bucket.grantPut(lambda);

    // Create an SQS queue
    const queue = new Queue(this, 'findansqsevent-sqs');

    // Invoke the lambda from the queue
    lambda.addEventSource(new SqsEventSource(queue, {
      batchSize: 10
    }));

    // Create an SNS topic
    const topic = new Topic(this, 'findansqsevent-sns');

    // Subscribe the queue to the topic
    topic.addSubscription(new SqsSubscription(queue));
  }
}
