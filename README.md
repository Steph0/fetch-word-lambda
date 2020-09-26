Lambda fetch-word
==================

# Description

Testing AWS Lambda functions

* index.js: entry-point containing function definition
* aws-config
  * trust-policy: to use AWS cli and configure IAM
  * scripts to build, deploy and use your lambda using AWS CLI, using npm

# AWS manual delivery

So far delivery is manual to learn using AWS CLI before using any other high level tools.
These scripts work on any terminal that can run bash scripts.

## Package

Package the handler for AWS.
Use `npm run build`, it will create a local file called `function.zip` (filename ignored by git to avoid pushing it).

## Initalize Lambda on AWS

**First time use?** You'll need to create the Lambda on AWS. You will need that step only the first time.
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