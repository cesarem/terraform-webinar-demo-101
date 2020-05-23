#!/usr/bin/python3
import json
import sys
import boto3

with open(sys.argv[1]) as f:
  data = json.load(f)

artifact_id = (data['builds'][0]['artifact_id'])
region, image_id = artifact_id.split(':')

#print (image_id)
client = boto3.client('ssm')
response = client.put_parameter(
    Name='flugel-it-image_id',
    Description='Instance Image ID for Flugel Test',
    Value=image_id,
    Type='String',
    Overwrite=True,
    Tier='Standard'
)

print(response)
