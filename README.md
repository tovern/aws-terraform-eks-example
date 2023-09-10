# aws-terraform-eks-example

## Overview
This example code uses Terraform to generate the EKS & RDS resources required to run a sample Python application. The code is the build with GitHub Actions and deployed to Kubernetes via FluxCD

## Caveats
Remote Terraform state does not exist. This should in reality be stored in a HA location such as S3 or Terraform cloud.

The Private key is stored unencrypted. In reality these secrets should be stored somewhere secure such as AWS Secrets Manager/Vault

## Prerequisites

* [FluxCD CLI](https://fluxcd.io/)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Terraform >=1.3.1](https://developer.hashicorp.com/terraform/downloads)

## Components

### application

The python application which is build with GitHub Actions (.github/workflows/docker-build-publish.yml)

### terraform

The Terraform code to provision the environment (Network, EKS, RDS, etc)

### flux-ops

The code used to bootstrap FluxCD onto the EKS cluster and install key components (cluster-autoscaler, external-secrets, etc)

### flux-apps

The code used to deploy the application to FluxCD
