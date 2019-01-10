#!/bin/bash
#
# This script is to deploy DevOps tools set 
# 1. Discovery Tool - ManageIQ
# 2. Provisioning Tool - Ansible
# 3. App Deployment Tool - Jenkins

# Pre-requisites to run this script
# Ensure kubectl is installed and configured to connect to K8S cluster
echo "checking Kubernetes connectivity"
echo "--------------------------------"
kubectl cluster-info
if [ $? -ne 0 ]
then
    echo "Looks like Kubernetes is not configured"
    echo "Please check and try to run script again.. Exiting"
    exit 1
else
    echo "Kubernetes is working.. Proceeding"
fi

#-------------------------------
# Installing Manage IQ container
#-------------------------------
#
echo "Installing discovery tool  - ManageIQ"
echo "-------------------------------------"
kubectl create deployment discoveryapp --image=manageiq/manageiq:gaprindashvili-7
if [ $? -ne 0 ]
then
    echo "The App deploy did not complete successfully"
    echo "Please check... Exiting"
    exit 
else
    echo "ManageIQ deploy completed successfully"
fi


echo "Starting services for ManageIQ"
echo "-------------------------------------"
kubectl expose deployment discoveryapp --port 443 --target-port 443 --type LoadBalancer
if [ $? -ne 0 ]
then
    echo "The services did not start successfully"
    echo "Please check... Exiting"
    exit 
else
    echo "ManageIQ services started successfully"
fi

#-------------------------------
# Installing Jenkins container
#-------------------------------
#
echo "Installing App Deployment tool  - Jenkins"
echo "-------------------------------------"
kubectl create deployment jenkinsapp --image=jenkinsci/blueocean
if [ $? -ne 0 ]
then
    echo "The App deploy did not complete successfully"
    echo "Please check... Exiting"
    exit 
else
    echo "Jenkins deploy completed successfully"
fi


#read pause

echo "Checking status of jenkins container"
STATUS=""
STATUS=`kubectl get pods | grep jenkinsapp  | awk '{print $3}'`
while [[ ${STATUS} != "Running" ]]
do
   echo "The app is not fully up yet.. Waiting to come up..."
   sleep 1
done
STATUS=""
echo "The app POD is up and running now"
#read pause

echo "Starting services for Jenkins"
echo "-------------------------------------"
kubectl expose deployment jenkinsapp --port 80 --target-port 8080 --type LoadBalancer
if [ $? -ne 0 ]
then
    echo "The services did not start successfully"
    echo "Please check... Exiting"
    exit 
else
    echo "Jenkins services started successfully"
fi
#read pause

echo "Checking status of jenkins container services"
STATUS=""
STATUS=`kubectl get services | grep jenkinsapp  | awk '{print $4}'`
echo ${STATUS}
while [[ ${STATUS} == "pending" ]]
do
   echo "The service is not fully up yet.. Waiting to come up..."
   sleep 1
done
STATUS=""
echo "The app services is up and running now"
#read pause


#-------------------------------
# Installing Ansible container
#-------------------------------
#
echo "Installing Provisioning Tool - Ansible"
echo "--------------------------------------"
kubectl create deployment ansibleapp --image=ybalt/ansible-tower

if [ $? -ne 0 ]
then
    echo "The App deploy did not complete successfully"
    echo "Please check... Exiting"
    exit 
else
    echo "Jenkins deploy completed successfully"
fi
#read pause

echo "Checking status of Ansible container"
STATUS=`kubectl get pods | grep ansibleapp  | awk '{print $3}'`
echo ${STATUS}
while [ ${STATUS} != "Running" ]
do
   echo "The app is not fully up yet.. Waiting to come up..."
   sleep 1
done
STATUS=""
echo "The app POD is up and running now"
#read pause

echo "Starting services for Ansible"
echo "-------------------------------------"
kubectl expose deployment ansibleapp --port 443 --target-port 443 --type LoadBalancer
if [ $? -ne 0 ]
then
    echo "The services did not start successfully"
    echo "Please check... Exiting"
    exit 
else
    echo "Ansible services started successfully"
fi
#read pause

echo "Checking status of Ansible container services"
STATUS=`kubectl get services | grep ansibleapp  | awk '{print $4}'`
echo ${STATUS}
while [ ${STATUS} == "pending" ]
do
   echo "The service is not fully up yet.. Waiting to come up..."
   sleep 1
done
STATUS=""
echo "The app services is up and running now"
