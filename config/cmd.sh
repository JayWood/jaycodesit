#!/usr/bin/env bash

set -euo pipefail;

echo "Entrypoint override"
if mount | grep -q /var/www/html/wp-content; then
  # entrypoint from Wordpress initializes /var/www/html; ignores wp-content directory
  # If this is bind-mounted, it's a "development area".
  echo "/var/www/html/wp-content is mounted, skipping";
else
  # This is done because a volume is mapped on /var/www/html - otherwise on each startup the tree would get populated in an unnamed volume
  # resulting in many dangling volumes.

  echo "Re-initializing /var/www/html ...";
  rm -fr /var/www/html/*;
fi

echo "Preventing exec call from original entrypoint.";
sed -i 's#exec "$@"##' /usr/local/bin/docker-entrypoint.sh

echo "Executing built-in entrypoint";
. /usr/local/bin/docker-entrypoint.sh "$@";

# Check if the database has tables
if wp db tables --allow-root | grep -q "wp_"; then
  echo "Database already has tables, skipping wp core install"
else
  echo "Database is empty, running wp core install"
  wp core install --url="${WORDPRESS_URL}" --title="${WORDPRESS_TITLE}" --admin_user="${WORDPRESS_ADMIN_USER}" --admin_password="${WORDPRESS_ADMIN_PASSWORD}" --admin_email="${WORDPRESS_ADMIN_EMAIL}" --skip-email --allow-root
fi

wp theme activate papanek --allow-root;

exec "$@";
