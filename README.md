# Find an SQS Event

This repository provides:

* A [stack](lib/body-filter.ts) that sets up the following infrastructure:

![Container diagram showing an SNS Topic publishing to an SQS Queue, which invokes a Lambda, which then writes to an S3 Bucket](body-filter.png)

## Build and deploy the demo stack

* `npm install`     install dependencies
* `npm run build`   compile typescript to js
* `cdk deploy`      deploy this stack to your default AWS account/region
