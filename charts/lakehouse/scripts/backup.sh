#!/usr/bin/env bash
set -euo pipefail

date_str="$(date +%Y-%m-%d)"
hour="$(date +%H)"
s3_base="https://${S3_ENDPOINT}/${S3_BUCKET}/clickhouse/backups/${date_str}/base"
s3_incr="https://${S3_ENDPOINT}/${S3_BUCKET}/clickhouse/backups/${date_str}/${hour}"

ch_client() {
	clickhouse-client \
		--host "${CLICKHOUSE_HOST}" \
		--port 9000 \
		--user "${CLICKHOUSE_USER}" \
		--password "${CLICKHOUSE_PASSWORD}" \
		"$@"
}

if [ "${hour}" = "00" ]; then
	echo "Creating base backup for ${date_str}"
	ch_client --query "BACKUP DATABASE ${CLICKHOUSE_DATABASES} TO S3('${s3_base}')"
	echo "Base backup complete"
else
	echo "Creating incremental backup for hour ${hour}"
	ch_client --query "BACKUP DATABASE ${CLICKHOUSE_DATABASES} TO S3('${s3_incr}') SETTINGS base_backup = S3('${s3_base}')"
	echo "Incremental backup complete"
fi
