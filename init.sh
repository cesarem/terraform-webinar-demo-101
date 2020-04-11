#!/bin/bash
apt-get install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
export LB_HOST=flugel-alb-1-1630873939.us-east-1.elb.amazonaws.com
export AWS_REGION=us-east-1
export AWS_BUCKET=flugel-test1-bucket
git clone https://github.com/cesaramaya-flugel/reverse-proxy.git
cd reverse-proxy
docker-compose up -d