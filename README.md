Lambda fetch-word
==================

# Description

AWS Lambda function code and deployment testing. Please note that repo is a playground around AWS Lambda functions.

* index.js: entry-point containing function definition
* aws-config
  * trust-policy: to use AWS cli and configure IAM
  * scripts to build, deploy and use your lambda using AWS CLI, using npm
* terraform: contains config to deploy and expose an AWS Lambda via AWS API Gateway

# Deployment using Terraform

You can use Terraform to deploy this Lambda using config in the [terraform](./terraform) folder.
This config:
* Packages the Lambda
* Deploys it on AWS Lambda as 'fetch-word-lambda'
* Creates API resource on AWS API Gateway on a "GET /" endpoint, and integrates the Lambda to it
* Exposes it on a stage "prod"

Note that terraform state files, and build files, are ignored by Git.

# AWS manual delivery

This part uses AWS CLI directly to delivery a Lambda. Note that it does not handle the API Gateway exposure part.
These scripts work on any terminal that can run bash scripts.

## Package

Package the handler for AWS.
Use `npm run build`, it will create a local file called `function.zip` (filename ignored by git to avoid pushing it).

## Initalize Lambda on AWS

**First time use?** You will need that step only the first time.
You will need a AWS role called 'lambda-execution' (not lambda-ex like in AWS CLI tutorial example).
You will also need an account ID that can deploy Lambda functions. Get it from your AWS account configured in AWS CLI or using AWS CLI with `aws iam get-user`.
Acccount ID can be found in your ARN, format `Arn: arn:aws:iam::<ACCOUNT_ID>:user/<USERNAME>`.

If this is unclear, please check out [AWS CLI section](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-awscli.html).
Checkout [./aws-config/create.sh](./aws-config/create.sh) file for more details.

Next step, create a file in `aws-config` directory, called `accountid` and containing your account ID value. This filename will be ignored by git to avoid pushing it.
Use `npm run create`. It will deploy the package to AWS to a Lambda called 'fetch-word-lambda'

## Update Lambda on AWS

You can deploy new versions by re-packaging your Lambda to a zip and running the update script.
Use `npm run build` to re-package. Then use `npm run update` to update remote Lambda on AWS.

## Trigger Lambda

Use `npm run invoke` to trigger your remote Lambda on AWS and get the logs. It will save Lambda output to a local `invoke.log` (filename ignored by git to avoid pushing it).
One liner could be `npm run invoke && cat invoke.log`