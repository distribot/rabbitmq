#!/bin/bash

set -euo pipefail


service rabbitmq-server start
sleep 5

rabbitmq-plugins enable rabbitmq_management

rabbitmqctl list_users

if rabbitmqctl list_users | grep $RABBITMQ_DEFAULT_USER; then
  echo "user '$RABBITMQ_DEFAULT_USER' already exists"
else
  echo 'adding user.....'
  set
  rabbitmqctl add_user $RABBITMQ_DEFAULT_USER $RABBITMQ_DEFAULT_PASS || echo 'weird...'
fi

if rabbitmqctl list_users | grep $RABBITMQ_DEFAULT_USER | grep -F "[administrator]"; then
  echo "user '$RABBITMQ_DEFAULT_USER' already tagged as 'administrator'"
else
  echo 'set user tags'
  rabbitmqctl set_user_tags $RABBITMQ_DEFAULT_USER administrator
fi

rabbitmqctl add_vhost $RABBITMQ_DEFAULT_USER || echo "vhost '$RABBITMQ_DEFAULT_USER' already exists"

if rabbitmqctl list_permissions -p $RABBITMQ_DEFAULT_USER | grep $RABBITMQ_VHOST | grep "$RABBITMQ_VHOST\\.\\*\\s+\\.\\*\\s+\\.\\*\$/"; then
  echo "user '$RABBITMQ_DEFAULT_USER' already has permissions '.* .* .*'"
else
  echo 'setting permissions'
  rabbitmqctl set_permissions -p $RABBITMQ_DEFAULT_USER $RABBITMQ_VHOST ".*" ".*" ".*"
fi

service rabbitmq-server stop

for f in /docker-entrypoint-init.d/*; do
  case "$f" in
    *.sh)     echo "$0: running $f"; . "$f" ;;
    *)        echo "$0: ignoring $f" ;;
  esac
done

exec "$@"
