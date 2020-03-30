#!/bin/bash
echo "Hello World! from public subnet" > index.html
nohup busybox httpd -f -p 8080 &