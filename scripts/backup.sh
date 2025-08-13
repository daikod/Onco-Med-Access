#!/bin/bash
# backup.sh
# Simple database backup script

set -euo pipefail

DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="/backups/oncology_db_backup_${DATE}.sql.gz"

echo "Starting database backup to ${BACKUP_FILE}..."

pg_dump -h db -U "${POSTGRES_USER:-oncology_user}" -d "${POSTGRES_DB:-oncology_db}" | gzip > "${BACKUP_FILE}"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Backup successful!"
    # Optional: Clean up old backups (e.g., older than 7 days)
    find /backups -type f -name '*.sql.gz' -mtime +7 -delete
    echo "Old backups cleaned up."
else
    echo "Backup failed!"
    rm -f "${BACKUP_FILE}" # Clean up failed backup file
    exit 1
fi

echo "Backup process complete."
