import os

import boto3


def lambda_handler(event, context):
  cluster = os.getenv('CLUSTER')
  service_name = os.getenv('SERVICE_NAME')

  client = boto3.client('ecs')

  response = client.list_tasks(
    cluster=cluster,
    serviceName=service_name,
    desiredStatus='RUNNING',
  )
  if len(response['taskArns'][0]) > 0:
    task = response['taskArns'][0]
    response = client.stop_task(
      cluster=cluster,
      task=task,
      reason='SSM changed'
    )
    print(response)

if __name__ == '__main__':
  lambda_handler(None, None)
