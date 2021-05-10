#!/usr/bin/env sh

AUTHORIZED_KEYS=$(aws ssm get-parameter --name /prod/bastion/pubkey | jq -r '.Parameter.Value')

mkdir -p /home/sshuser/.ssh && \
    echo "$AUTHORIZED_KEYS" > /home/sshuser/.ssh/authorized_keys && \
    chmod 400 /home/sshuser/.ssh/authorized_keys && \
    chown -R sshuser:bastion /home/sshuser/.ssh


if [ -z "$BASTION_URL" ] || [ -z "$HOSTED_ZONE_ID" ]
then
  echo "Missing BASTION_URL or HOSTED_ZONE_ID variable. Will not create route53 entry"
else
  PUBLIC_IP=$(curl ifconfig.me)

  ROUTE53=$(cat route53.json)
  ROUTE53=$(echo "$ROUTE53" | sed "s/\[bastion_ip\]/$PUBLIC_IP/g")
  ROUTE53=$(echo "$ROUTE53" | sed "s/\[bastion_url\]/$BASTION_URL/g")

  echo "$ROUTE53" > route53.json

  aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch file://route53.json
fi


/usr/sbin/sshd -D -E /proc/1/fd/1
