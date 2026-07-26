#!/bin/sh
set -eu

BACKUP_PATH="clickhouse/backups"
RETENTION="${RETENTION:-7}"

mc alias set local "${S3_ENDPOINT}" "${AWS_ACCESS_KEY_ID}" "${AWS_SECRET_ACCESS_KEY}"

count=0

mc ls "local/${S3_BUCKET}/${BACKUP_PATH}/" | awk '{print $2}' | sed 's|/$||' | sort -r | while read -r dir; do
	count=$((count + 1))

	if [ "$count" -gt "$RETENTION" ]; then
		echo "Deleting old backup chain: ${dir}"
		mc rm --recursive --force "local/${S3_BUCKET}/${BACKUP_PATH}/${dir}/"
	else
		echo "Keeping backup chain: ${dir}"
	fi
done
