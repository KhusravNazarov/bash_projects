#!/bin/bash
# install zip
sudo apt install -y zip


# variables 
APP_HOME="/var/lib/jenkins" 
BACKUP_DIR="/backups/app"
S3_BUCKET="s3://backup-s3-name"
DATE=$(date +'%m-%d')
BACKUP_FILE="app_backup_$DATE.zip"

# create backup dir
sudo mkdir -p "$BACKUP_DIR"

# Check if app home directory exists
if [ ! -d "$APP_HOME" ]; then
    echo "app home directory not found: $APP_HOME" 
    exit 1
fi

# Create the backup
echo "Backing up application home directory..." 
sudo zip -r "$BACKUP_DIR/$BACKUP_FILE" "$APP_HOME"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful! Saved to $BACKUP_DIR/$BACKUP_FILE"
else
    echo "Backup failed!" 
    exit 1
fi

# Upload the backup to S3
echo "Uploading backup to S3..." 
aws s3 cp "$BACKUP_DIR/$BACKUP_FILE" "$S3_BUCKET/$BACKUP_FILE"

# Check if the upload was successful
if [ $? -eq 0 ]; then
    echo "Upload successful! File available at $S3_BUCKET/$BACKUP_FILE" 
else
    echo "Upload failed!"
    exit 1
fi

# Remove backups older than 7 days
find "$BACKUP_DIR" -type f -name "*" -mtime +7 -exec rm {} \;

echo "Old backups cleaned up." 
