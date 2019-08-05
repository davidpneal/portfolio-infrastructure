#!/bin/bash
#8/4/2019
#This scrip will install the required components to run the flask application

yum update -y
yum install python3 -y
pip3 install flask
pip3 install flask-wtf
pip3 install flask-sqlalchemy
