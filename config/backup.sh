#!/bin/bash

PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin

# Read the environment variables from /proc/1/environ, replace null chars with newlines
env_vars=$(tr '\0' '\n' < /proc/1/environ)

# Export each environment variable
while IFS= read -r var; do
    export "$var"
done <<< "$env_vars"

# Variables
LOCK_FILE="/var/www/html/wp-content/backup.lock"
WP_PATH="/var/www/html"
EXPORT_DIR="/tmp/export"
UPLOADS_DIR="$EXPORT_DIR/uploads"
BACKUP_FILE="/tmp/wp-backup-$(date +'%F-%H%M%S').tar.gz"
SERVICE_ACCOUNT_JSON="/var/secrets/google/jaycodesit-f6c85665a3fc.json"
GDRIVE_FOLDER_ID="1C0d_bBfEwHtEgVmwGn8ohE4KqSa30-QE"
OAUTH_TOKEN_ENDPOINT="https://oauth2.googleapis.com/token"
GDRIVE_UPLOAD_ENDPOINT="https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"

# Check for existing lock file
if [ -f "$LOCK_FILE" ]; then
    echo "Backup is already running. Exiting..."
    exit 1
fi

# Create lock file
touch "$LOCK_FILE"
echo "Backup started..."

# Cleanup previous export if exists
rm -rf "$EXPORT_DIR"
mkdir -p "$UPLOADS_DIR"

# Export the database using WP CLI
echo "Exporting database..."
wp db export --allow-root --path="$WP_PATH" "$EXPORT_DIR/db-export.sql"

if [ $? -ne 0 ]; then
    echo "Database export failed!"
    rm -f "$LOCK_FILE"
    exit 1
fi

# Copy the wp-content/uploads folder to /tmp/export/uploads
echo "Copying uploads directory..."
cp -r "$WP_PATH/wp-content/uploads" "$UPLOADS_DIR"

if [ $? -ne 0 ]; then
    echo "Failed to copy uploads directory!"
    rm -f "$LOCK_FILE"
    exit 1
fi

# Create a tarball of the export directory
echo "Creating tarball..."
tar -czf "$BACKUP_FILE" -C "$EXPORT_DIR" .

if [ $? -ne 0 ]; then
    echo "Failed to create tarball!"
    rm -f "$LOCK_FILE"
    exit 1
fi

# Extract variables from the service account JSON
PRIVATE_KEY=$(jq -r '.private_key' "$SERVICE_ACCOUNT_JSON")
CLIENT_EMAIL=$(jq -r '.client_email' "$SERVICE_ACCOUNT_JSON")

# Create the JWT Header
JWT_HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Create the JWT Claim Set
NOW=$(date +%s)
EXP=$(($NOW + 3600))
JWT_CLAIM=$(echo -n '{
  "iss": "'$CLIENT_EMAIL'",
  "scope": "https://www.googleapis.com/auth/drive.file",
  "aud": "'$OAUTH_TOKEN_ENDPOINT'",
  "exp": '$EXP',
  "iat": '$NOW'
}' | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Create the JWT Signature
JWT_SIGNATURE=$(echo -n "${JWT_HEADER}.${JWT_CLAIM}" | openssl dgst -sha256 -sign <(echo -n "$PRIVATE_KEY") | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

# Combine JWT components into a single token
JWT="${JWT_HEADER}.${JWT_CLAIM}.${JWT_SIGNATURE}"

# Exchange JWT for an OAuth2 access token
ACCESS_TOKEN=$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${JWT}" \
    "$OAUTH_TOKEN_ENDPOINT" | jq -r '.access_token')

# Upload the tarball to Google Drive
echo "Uploading tarball to Google Drive..."
curl -X POST -L \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -F "metadata={name :'$(basename $BACKUP_FILE)', parents: ['$GDRIVE_FOLDER_ID']};type=application/json;charset=UTF-8" \
    -F "file=@$BACKUP_FILE;type=application/gzip" \
    "$GDRIVE_UPLOAD_ENDPOINT"

if [ $? -ne 0 ]; then
    echo "Failed to upload tarball to Google Drive!"
    rm -f "$LOCK_FILE"
    exit 1
fi

# Cleanup
echo "Cleaning up..."
rm -rf "$EXPORT_DIR"
rm -f "$BACKUP_FILE"
rm -f "$LOCK_FILE"

echo "Backup completed successfully."
