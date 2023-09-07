cat hd.sh 
#!/bin/bash

# Set the database credentials
DB_USER="root"
DB_PASSWORD="password"
DB_NAME="jamtech"

# Set the backup directory
BACKUP_DIR="/home/jame269/bkp_data"

# Get the current date in the desired format (e.g., 07sep2023)
DATE_SUFFIX=$(date +"%d%b%Y")

# Set the backup filename with the date suffix
BACKUP_FILENAME="db_$DATE_SUFFIX.sql"

# Generate the backup file
mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/$BACKUP_FILENAME

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Database backup completed successfully."
else
    echo "Error: Database backup failed."
    exit 1
fi

# Create a tar archive of the backup file
tar -czf $BACKUP_DIR/$BACKUP_FILENAME.tar.gz -C $BACKUP_DIR $BACKUP_FILENAME

# Check if tar archive creation was successful
if [ $? -eq 0 ]; then
    echo "Backup file archived successfully."
else
    echo "Error: Backup file archiving failed."
    exit 1
fi

# Set the physical hard drive path
PHYSICAL_HARD_DRIVE_PATH="/mnt/external/backups"

# Copy the backup file to the physical hard drive
cp $BACKUP_DIR/$BACKUP_FILENAME.tar.gz $PHYSICAL_HARD_DRIVE_PATH

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "Backup file copied to physical hard drive successfully."
else
    echo "Error: Backup file copy failed."
    exit 1
fi

# deletion of the .sql file
# rm -f "$BACKUP_DIR/$BACKUP_FILENAME"
# echo "Local .sql backup file deleted."
