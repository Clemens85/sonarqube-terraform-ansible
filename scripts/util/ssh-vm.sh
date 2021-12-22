#! /bin/bash

CUR_DIR_TF=$(pwd)

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

STAGE=$1

./allow-ssh-access.sh "$STAGE"

remoteHostIp=$(../../terraform/tf.sh "$STAGE" app output -raw webserver_ip)
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "sonarqube-admin@${remoteHostIp}" 
if [ $? -ne 0 ]; then
  echo "Skip removal of SSH access due to it seems like that Azure was too slow... just execute again..."
else
  ./remove-ssh-access.sh "$STAGE"
fi

cd "$CUR_DIR" || exit 1 