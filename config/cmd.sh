#!/usr/bin/env bash

echo "Entrypoint override"
if mount | grep -q /var/www/html/wp-content
then
  # entrypoint from Wordpress initializes /var/www/html; ignores wp-content directory
  # If this is bind-mounted, it's a "development area".
  echo "/var/www/html/wp-content is mounted, skipping"
else
  # This is done because a volume is mapped on /var/www/html - otherwise on each startup the tree would get populated in an unnamed volume
  # resulting in many dangling volumes.

  echo "Re-initializing /var/www/html ..."
  rm -fr /var/www/html/*
fi

echo "Executing built-in entrypoint"
exec /usr/local/bin/docker-entrypoint.sh "$@"
