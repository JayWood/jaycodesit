#!/usr/bin/env bash

set -euox pipefail

echo "Made it here"
#wp site list --allow-root

# Run the original foreground.
apache2-foreground

exec "$@"
