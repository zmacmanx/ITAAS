#!/bin/bash
# Here is the documentation followed for scripting the mesos setup with terraform
#  "https://docs.mesosphere.com/1.12/installing/evaluation/aws/"

# Clear any old cluster setup
CLUSTER_NAME=`dcos cluster list | grep -v NAME |awk '{print $2}'`
dcos cluster remove ${CLUSTER_NAME}
if [ $? -ne 0 ]
then
   echo "Failed to remove the old cluster.. Please remove it manually"
   echo "Proceeding anyway.. "
fi

# Prerequisites:
#1. AWS Credentials
#2. Install aws-cli binary
#3. Install terraform binary
#   https://www.terraform.io/downloads.html
#   For Linux 64bit - https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
#4. Configure aws-cli 
#   pip install awscli --upgrade --user
#   aws configure --profile=mesos_terraform_profile
#5. Setup ssh key .. if you dont already have one

# Next steps are for terrform setup for DS/OS setup
#1. Create directory for the project
PROJ_DIR="/home/shivan/test"
LOG_DIR="/home/shivan/project/"
> ${LOG_DIR}/mesos.setup.log
mkdir -p ${PROJ_DIR}
if [ $? -eq 0 ]
then
    echo "Project directory ${PROJ_DIR} has been created or its exists"
    echo "Proceeding.... "
    echo ""
else
    echo "Failed to create ${PROJ_DIR}"
    echo "Exiting"
    exit
fi
cd ${PROJ_DIR}

# Setup log directory for logging purposes
mkdir -p ${LOG_DIR}
if [ $? -eq 0 ]
then
    echo "Log directory ${LOG_DIR} has been created or its exists"
    echo "Proceeding.... "
    echo ""
else
    echo "Failed to create ${LOG_DIR}"
    echo "Exiting"
    exit
fi

#2. create main.tf
DEFAULT_REGION="us-east-1"
SSH_PUB_KEY="~/.ssh/id_rsa.pub"
   
if [ ! -f ${PROJ_DIR}/main.tf ]
then
    echo "main.tf does not exist"
    echo "please check and rerun... exiting"
    exit
else
    echo "main.tf exists.. proceeding."
fi

# Initialize terraform
echo "Initializing terraform..."
terraform init -input=false > ${LOG_DIR}/mesos.setup.log

# Save the plan
echo "Saving the terraform plan.. "
terraform plan -out=plan.out >> ${LOG_DIR}/mesos.setup.log

# apply the plan
echo "Kicking off the resources from the plan"
terraform apply -auto-approve plan.out >> ${LOG_DIR}/mesos.setup.log
URL=`grep cluster-address ${LOG_DIR}/mesos.setup.log | awk -F= '{print $2}' | sed 's/^ *//g'`
CLUSTER_URL="http://${URL}"
echo URL=$URL
echo CLUSTER_URL=${CLUSTER_URL}

echo "----------------------------------------------------"
echo "Run cluster setup using the command listed below"
echo "It should pop up a window to authenticate. Copy the contents to clipboard as mentioned on the UI and close the browser window"
echo "Paste the content back on the terminal prompt"
echo "----------------------------------------------------"
echo "dcos cluster setup ${CLUSTER_URL}"
echo "----------------------------------------------------"

echo "Here is the cluster info"
dcos cluster list

echo "Setup marathon UI by going to this link listed below"
echo "----------------------------------------------------"
echo "${CLUSTER_URL}/service/marathon"

