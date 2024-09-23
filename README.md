This repository provides a fully automated process to set up a Kubernetes cluster on AWS using **Kops**, **Terraform**, and **Ansible**. 

## Prerequisites

- A domain name (Route53 configured)
- AWS account with sufficient permissions
- An S3 bucket for Kops state store
- IAM Role with EC2 and S3 permissions assigned to the management server
- A management EC2 instance (referred to as `managementserver`) for running the automation

## Setup Instructions

### 1. Infrastructure Setup

```
terraform init
terraform apply --auto-approve
```
### 2. configuration
```
 ansible-playbook -i host configure_ec2_kops.yml -vvv
```
## The setup will create a Kubernetes cluster consisting of **1 master node** and **2 worker nodes**.
