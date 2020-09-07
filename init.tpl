#!/bin/bash
export LB_HOST=${lb_host}
export AWS_REGION=${region}
export AWS_BUCKET=${bucket}
cd /opt/crew/reverse-proxy
docker-compose up -d