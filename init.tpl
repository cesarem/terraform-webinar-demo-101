#!/bin/bash
export LB_HOST=${lb_host}
export AWS_REGION=${region}
export AWS_BUCKET=${bucket}
cd /opt/flugel-it/reverse-proxy
docker-compose up -d