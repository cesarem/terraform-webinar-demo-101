#!/bin/bash
export LB_HOST=${lb_host}
export AWS_REGION=${region}
export AWS_BUCKET=${bucket}
git clone https://github.com/cesaramaya-flugel/reverse-proxy.git
cd reverse-proxy
docker-compose up -d