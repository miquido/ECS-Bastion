import json
import os

import boto3


def lambda_handler(event, context):
  keys = next(filter(lambda x: x == 'keys.txt', map(lambda x: x['s3']['object']['key'], event['Records'])), None)
  if keys is None:
    return

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
      reason='Pubkeys changed'
    )
    print(response)


def mock_message(file_name):
  parent_dir = os.path.dirname(os.path.abspath(__file__))

  with open(f'{parent_dir}/fixtures/{file_name}.json', 'r') as f:
    return json.load(f)


if __name__ == '__main__':
  lambda_handler(mock_message('s3_changed'), None)
