#!/bin/bash
echo "Hello World from private subnet" > index.html
nohup busybox httpd -f -p 80 &