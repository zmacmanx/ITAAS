#!/bin/bash
#
#Clone and build this Git project.
#Clone this Git repository in your development environment if you haven't already done so.

git clone shi-development@vs-ssh.visualstudio.com:v3/shi-development/IaC/infra-ci-cd-demo
cd infra-ci-cd-demo

# Install the dependencies.
npm install

# Compile the TypeScript files.
npm run build

# Create a CodeCommit  repository for a web application.
# Synthesize a CloudFormation template.
cb synth stacks/developer-tools/codecommit/repository

# Create a CloudFormation stack.
aws cloudformation create-stack --stack-name    codecommit-repository-app-ci-cd-demo \
                                --template-body file://stacks/developer-tools/codecommit/repository.template.yaml

# Clone the new Git repository in your development environment.
cd ..
git clone ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/app-ci-cd-demo

# Copy the contents of web-application into the new Git repository.
cd app-ci-cd-demo
cp -a ../infra-ci-cd-demo/web-application/* .
git add .
git commit -m "Add initial files"
git push

# Create an S3  bucket to store artifacts (skip if you want to use an existing bucket for artifacts).
# Replace {BUCKET_NAME} with your bucket name in bucket.props.yaml. Ex. If your bucket name was artifacts-123, use:
BUCKET_NAME_VALUE="artifacts-774461968944"
cd ../infra-ci-cd-demo
sed -i 's/{BUCKET_NAME}/${BUCKET_NAME_VALUE}/g' stacks/storage/s3/bucket.props.yaml

# Synthesize a CloudFormation template.
cb synth stacks/storage/s3/bucket

# Create a CloudFormation stack. Replace {BUCKET_NAME} with your bucket name.
aws cloudformation create-stack --stack-name    s3-bucket-${BUCKET_NAME_VALUE} \
                                --template-body file://stacks/storage/s3/bucket.template.yaml

# Replace variables in stack files.
# Replace {BUCKET_NAME} with your artifacts bucket name in stack files. Ex. If your bucket name was artifacts-123, use:
grep -rl {BUCKET_NAME} ./stacks | xargs sed -i 's/{BUCKET_NAME}/${BUCKET_NAME_VALUE}/g'

# Replace {ACCOUNT_ID} with your AWS account ID in stack files. Ex. If your account ID was 123, use:
ACCOUNT_ID_VALUE="774461968944"
grep -rl {ACCOUNT_ID} ./stacks | xargs sed -i 's/{ACCOUNT_ID}/${ACCOUNT_ID_VALUE}/g'

# Create a CloudFormation template for Cloud9  and save it in the artifacts bucket.
# Synthesize a CloudFormation template.
cb synth stacks/developer-tools/cloud9/environment-ec2

#b. Copy the synthesized CloudFormation template up to the artifacts bucket. Replace {BUCKET_NAME} with your bucket name.
aws s3 cp stacks/developer-tools/cloud9/environment-ec2.template.yaml \
    s3://${BUCKET_NAME_VALUE}/infra-ci-cd-demo/stacks/developer-tools/cloud9/environment-ec2.template.yaml

#Create IAM  roles for Lambda, EC2, CodeDeploy, CodePipeline and CloudWatch Events.
#a. Synthesize CloudFormation templates.
cb synth stacks/security-identity-compliance/iam/role-1
cb synth stacks/security-identity-compliance/iam/role-2
cb synth stacks/security-identity-compliance/iam/role-3
cb synth stacks/security-identity-compliance/iam/role-4
cb synth stacks/security-identity-compliance/iam/role-5

#b. Create CloudFormation stacks.
aws cloudformation create-stack --stack-name    iam-role-lambda-infra-ci-cd-demo \
                                --template-body file://stacks/security-identity-compliance/iam/role-1.template.yaml \
                                --capabilities  CAPABILITY_NAMED_IAM
aws cloudformation create-stack --stack-name    iam-role-ec2-infra-ci-cd-demo \
                                --template-body file://stacks/security-identity-compliance/iam/role-2.template.yaml \
                                --capabilities  CAPABILITY_NAMED_IAM
aws cloudformation create-stack --stack-name    iam-role-codedeploy-infra-ci-cd-demo \
                                --template-body file://stacks/security-identity-compliance/iam/role-3.template.yaml \
                                --capabilities  CAPABILITY_NAMED_IAM
aws cloudformation create-stack --stack-name    iam-role-codepipeline-infra-ci-cd-demo \
                                --template-body file://stacks/security-identity-compliance/iam/role-4.template.yaml \
                                --capabilities  CAPABILITY_NAMED_IAM
aws cloudformation create-stack --stack-name    iam-role-events-infra-ci-cd-demo \
                                --template-body file://stacks/security-identity-compliance/iam/role-5.template.yaml \
                                --capabilities  CAPABILITY_NAMED_IAM

#Create Lambda  functions for CloudWatch Events rules.
#a. Replace {CLOUD9_OWNER_ARN} with the IAM user ARN for the Cloud9 user in function-1.js. Ex. If your user ARN was arn:aws:iam::123:user/john, use (remember to escape '/'):
CLOUD9_OWNER_ARN="arn:aws:iam::774461968944:user/DevOpsAdmin"
CLOUD9_OWNER_ARN_VALUE=`echo ${CLOUD9_OWNER_ARN} | awk -F'/' -v OFS='\\\/' '$1=$1'`
cd stacks/compute/lambda
sed -i 's/{CLOUD9_OWNER_ARN}/${CLOUD9_OWNER_ARN_VALUE}' function-1.js

#b. Replace {CLOUD9_GIT_USER_NAME} with the Cloud9 user's IAM user name in function-3.js. Ex. If the user name was john, use:
GIT_USER=`echo ${CLOUD9_OWNER_ARN} | awk -F'/' '{print $2}'` 
sed -i 's/{CLOUD9_GIT_USER_NAME}/${GIT_USER}/' function-3.js

#c. Zip the Lambda functions and copy them up to the artifacts bucket. Replace {BUCKET_NAME} with your bucket name.
PATH=""
zip function-1.zip function-1.js
zip function-2.zip function-2.js
zip function-3.zip function-3.js
aws s3 cp function-1.zip s3://${BUCKET_NAME_VALUE}/${PATH}/function-1.zip
aws s3 cp function-2.zip s3://${BUCKET_NAME_VALUE}/${PATH}/function-2.zip
aws s3 cp function-3.zip s3://${BUCKET_NAME_VALUE}/${PATH}/function-3.zip

#d. Replace {S3_OBJECT_VERSION} with your version ID in function-1.props.yaml. Ex. If your S3 object version for {BUCKET_NAME}/infra-ci-cd-demo/function-1.zip was 4dslN0e113X8C4dFAQzjLW85M7rnrZVs, use:
S3_OBJECT_VERSION_VALUE=""
sed -i 's/{S3_OBJECT_VERSION}/${S3_OBJECT_VERSION_VALUE}/' function-1.props.yaml

#e. Replace {S3_OBJECT_VERSION} with your version ID in function-2.props.yaml. Ex. If your S3 object version for {BUCKET_NAME}/infra-ci-cd-demo/function-2.zip was B.eEH8lBSb46aHHEY3NDe33CQoj3TfV2, use:
sed -i 's/{S3_OBJECT_VERSION}/${S3_OBJECT_VERSION_VALUE}/' function-2.props.yaml

#f. Replace {S3_OBJECT_VERSION} with your version ID in function-3.props.yaml. Ex. If your S3 object version for {BUCKET_NAME}/infra-ci-cd-demo/function-3.zip was Nm3ceBElvzkiE8BVZ.GKJGnNanKKsXA0, use:
sed -i 's/{S3_OBJECT_VERSION}/${S3_OBJECT_VERSION_VALUE}/' function-3.props.yaml

#g. Synthesize CloudFormation templates.
cb synth function-1
cb synth function-2
cb synth function-3

#h. Create CloudFormation stacks.
aws cloudformation create-stack --stack-name    lambda-function-infra-ci-cd-demo-1 \
                                --template-body file://function-1.template.yaml
aws cloudformation create-stack --stack-name    lambda-function-infra-ci-cd-demo-2 \
                                --template-body file://function-2.template.yaml
aws cloudformation create-stack --stack-name    lambda-function-infra-ci-cd-demo-3 \
                                --template-body file://function-3.template.yaml

#Create Lambda permissions for CloudWatch Events rules.
#a. Synthesize CloudFormation templates.
cb synth permission-1
cb synth permission-2
cb synth permission-3

#b. Create CloudFormation stacks.
aws cloudformation create-stack --stack-name    lambda-permission-infra-ci-cd-demo-1 \
                                --template-body file://permission-1.template.yaml
aws cloudformation create-stack --stack-name    lambda-permission-infra-ci-cd-demo-2 \
                                --template-body file://permission-2.template.yaml
aws cloudformation create-stack --stack-name    lambda-permission-infra-ci-cd-demo-3 \
                                --template-body file://permission-3.template.yaml

#Create CloudWatch  Events rules to trigger Lambda functions.
#a. Synthesize CloudFormation templates.
cd ../../..
cb synth stacks/management-governance/events/rule-1
cb synth stacks/management-governance/events/rule-2
cb synth stacks/management-governance/events/rule-3

#b. Create CloudFormation stacks.
aws cloudformation create-stack --stack-name    events-rule-infra-ci-cd-demo-1 \
                                --template-body file://stacks/management-governance/events/rule-1.template.yaml
aws cloudformation create-stack --stack-name    events-rule-infra-ci-cd-demo-2 \
                                --template-body file://stacks/management-governance/events/rule-2.template.yaml
aws cloudformation create-stack --stack-name    events-rule-infra-ci-cd-demo-3 \
                                --template-body file://stacks/management-governance/events/rule-3.template.yaml

#Create an IAM instance profile for an EC2 instance.
#a. Synthesize a CloudFormation template.
cb synth stacks/security-identity-compliance/iam/instance-profile

#b. Create a CloudFormation stack.
aws cloudformation create-stack --stack-name    iam-instance-profile-infra-ci-cd-demo \
                                --template-body file://stacks/security-identity-compliance/iam/instance-profile.template.yaml \
                                --capabilities  CAPABILITY_NAMED_IAM

#Create a security group for step 12.
#a. Replace {VPC_ID} with your VPC ID in security-group.props.yaml. Ex. If your VPC ID was vpc-7b280d01, use:
VPC_ID_VALUE=""
sed -i 's/{VPC_ID}/${VPC_ID_VALUE}/' stacks/compute/ec2/security-group.props.yaml

#b. Synthesize a CloudFormation template.
cb synth stacks/compute/ec2/security-group

#c. Create a CloudFormation stack.
aws cloudformation create-stack --stack-name    ec2-security-group-app-ci-cd-demo \
                                --template-body file://stacks/compute/ec2/security-group.template.yaml

#Create an EC2  instance for a web application.
#a. Replace {SECURITY_GROUP_ID} with your security group ID in instance.props.yaml. Ex. If your security group ID was sg-07b0bfb35a0bd5492, use:
SECURITY_GROUP_ID_VALUE=""
sed -i 's/{SECURITY_GROUP_ID}/${SECURITY_GROUP_ID_VALUE}/' stacks/compute/ec2/instance.props.yaml

#b. Replace {SUBNET_ID} with your subnet ID in instance.props.yaml. Ex. If your subnet ID was subnet-c6b072a1, use:
SUBNET_ID_VALUE=""
sed -i 's/{SUBNET_ID}/${SUBNET_ID_VALUE}/' stacks/compute/ec2/instance.props.yaml

#c. Synthesize a CloudFormation template.
cb synth stacks/compute/ec2/instance

#d. Create a CloudFormation stack.
aws cloudformation create-stack --stack-name    ec2-instance-app-ci-cd-demo \
                                --template-body file://stacks/compute/ec2/instance.template.yaml

#Create a CodeDeploy  application and deployment group.
#a. Synthesize CloudFormation templates.
cb synth stacks/developer-tools/codedeploy/application
cb synth stacks/developer-tools/codedeploy/deployment-group

#b. Create CloudFormation stacks.
aws cloudformation create-stack --stack-name    codedeploy-application-infra-ci-cd-demo \
                                --template-body file://stacks/developer-tools/codedeploy/application.template.yaml
aws cloudformation create-stack --stack-name    codedeploy-deployment-group-infra-ci-cd-demo \
                                --template-body file://stacks/developer-tools/codedeploy/deployment-group.template.yaml

#Create a CodePipeline  pipeline.
#a. Synthesize a CloudFormation template.
cb synth stacks/developer-tools/codepipeline/pipeline

#b. Create a CloudFormation stack.
aws cloudformation create-stack --stack-name    codepipeline-pipeline-infra-ci-cd-demo \
                                --template-body file://stacks/developer-tools/codepipeline/pipeline.template.yaml

#Create a CloudWatch Events rule to trigger a CodePipeline pipeline.
#a. Synthesize CloudFormation templates.
cb synth stacks/management-governance/events/rule-4

#b. Create CloudFormation stacks.
aws cloudformation create-stack --stack-name    events-rule-infra-ci-cd-demo-4 \
                                --template-body file://stacks/management-governance/events/rule-4.template.yaml

#Tear Down
aws cloudformation delete-stack --stack-name events-rule-infra-ci-cd-demo-4
aws cloudformation delete-stack --stack-name ec2-instance-app-ci-cd-demo
aws cloudformation wait stack-delete-complete --stack-name ec2-instance-app-ci-cd-demo
aws cloudformation delete-stack --stack-name ec2-security-group-app-ci-cd-demo
aws cloudformation delete-stack --stack-name iam-instance-profile-infra-ci-cd-demo
aws cloudformation wait stack-delete-complete --stack-name iam-instance-profile-infra-ci-cd-demo
aws cloudformation delete-stack --stack-name iam-role-ec2-infra-ci-cd-demo
aws cloudformation delete-stack --stack-name codepipeline-pipeline-infra-ci-cd-demo
aws cloudformation wait stack-delete-complete --stack-name codepipeline-pipeline-infra-ci-cd-demo
aws cloudformation delete-stack --stack-name codedeploy-deployment-group-infra-ci-cd-demo
aws cloudformation wait stack-delete-complete --stack-name codedeploy-deployment-group-infra-ci-cd-demo
aws cloudformation delete-stack --stack-name codedeploy-application-infra-ci-cd-demo
aws cloudformation wait stack-delete-complete --stack-name events-rule-infra-ci-cd-demo-4
aws cloudformation delete-stack --stack-name iam-role-events-infra-ci-cd-demo
aws cloudformation delete-stack --stack-name iam-role-codepipeline-infra-ci-cd-demo
aws cloudformation wait stack-delete-complete --stack-name codedeploy-application-infra-ci-cd-demo
aws cloudformation delete-stack --stack-name iam-role-codedeploy-infra-ci-cd-demo
aws cloudformation delete-stack --stack-name events-rule-infra-ci-cd-demo-3
aws cloudformation delete-stack --stack-name events-rule-infra-ci-cd-demo-2
aws cloudformation delete-stack --stack-name events-rule-infra-ci-cd-demo-1
aws cloudformation wait stack-delete-complete --stack-name events-rule-infra-ci-cd-demo-3
aws cloudformation wait stack-delete-complete --stack-name events-rule-infra-ci-cd-demo-2
aws cloudformation wait stack-delete-complete --stack-name events-rule-infra-ci-cd-demo-1
aws cloudformation delete-stack --stack-name lambda-permission-infra-ci-cd-demo-3
aws cloudformation delete-stack --stack-name lambda-permission-infra-ci-cd-demo-2
aws cloudformation delete-stack --stack-name lambda-permission-infra-ci-cd-demo-1
aws cloudformation wait stack-delete-complete --stack-name lambda-permission-infra-ci-cd-demo-3
aws cloudformation wait stack-delete-complete --stack-name lambda-permission-infra-ci-cd-demo-2
aws cloudformation wait stack-delete-complete --stack-name lambda-permission-infra-ci-cd-demo-1
aws cloudformation delete-stack --stack-name lambda-function-infra-ci-cd-demo-3
aws cloudformation delete-stack --stack-name lambda-function-infra-ci-cd-demo-2
aws cloudformation delete-stack --stack-name lambda-function-infra-ci-cd-demo-1
aws cloudformation wait stack-delete-complete --stack-name lambda-function-infra-ci-cd-demo-3
aws cloudformation wait stack-delete-complete --stack-name lambda-function-infra-ci-cd-demo-2
aws cloudformation wait stack-delete-complete --stack-name lambda-function-infra-ci-cd-demo-1
aws cloudformation delete-stack --stack-name iam-role-lambda-infra-ci-cd-demo
aws cloudformation delete-stack --stack-name codecommit-repository-app-ci-cd-demo
