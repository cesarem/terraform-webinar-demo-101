#!/bin/bash
yum update -y
#amazon-linux-extras install docker -y
#service docker start
#usermod -a -G docker ec2-user
#chkconfig docker on
yum install -y git
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#chgrp ec2-user /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
# export env vars
export LB_HOST=${lb_host}
export AWS_REGION=${region}
export AWS_BUCKET=${bucket}
git clone https://github.com/cesaramaya-flugel/reverse-proxy.git
cd reverse-proxy
docker-compose up -d