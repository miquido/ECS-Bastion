#!/usr/bin/env sh

mkdir -p /home/sshuser/.ssh && \
    aws s3 cp "s3://$KEYS_BUCKET/keys.txt" /home/sshuser/.ssh/authorized_keys && \
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
