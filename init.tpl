#!/bin/bash
apt-get install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
export LB_HOST=${lb_host}
export AWS_REGION=${region}
export AWS_BUCKET=${bucket}
git clone https://github.com/cesaramaya-flugel/reverse-proxy.git
cd reverse-proxy
docker-compose up -d