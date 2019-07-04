# portfolio-infrastructure

## Overview

This project is designed to be a demonstration of a simple CRUD application running in an environment provisioned via Infrastructure as Code.  This application will be tied into a CI\CD pipeline to handle deployments to prod and the other environments.  The goal is to automate as much of this process as possible.  The project is a work in progress - in lieu of the future web app, the servers use a simple Hello World page as a stand in for the time being.

This is the infrastructure repository which will stand up the underlying AWS infrastructure to host the website in a resilient manor.  It includes the following components:
* A VPC with subnets in multiple availability zones
* An autoscaling group for compute located behind a load balancer
* The load balancer is assigned a DNS name for easy access