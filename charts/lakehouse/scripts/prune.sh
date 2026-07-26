#!/bin/sh
set -eu

BACKUP_PATH="clickhouse/backups"
RETENTION="${RETENTION:-7}"

# List backup directories and keep only the newest RETENTION days
count=0
mc ls "s3://${S3_BUCKET}/${BACKUP_PATH}/" | awk '{print $2}' | sed 's|/$||' | sort -r | while read -r dir; do
	count=$((count + 1))
	if [ "${count}" -gt "${RETENTION}" ]; then
		echo "Deleting old backup chain: ${dir}"
		mc rm --recursive --force "s3://${S3_BUCKET}/${BACKUP_PATH}/${dir}/"
	else
		echo "Keeping backup chain: ${dir}"
	fi
done
