# iceberg-maintenance

Weekly CronJob that expires old Iceberg snapshots from the Nessie catalog.

## Usage

```bash
ICEBERG_NESSIE_URI=http://lakehouse-nessie:19120 \
ICEBERG_S3_ENDPOINT=https://nbg1.your-objectstorage.com \
ICEBERG_S3_ACCESS_KEY_ID=... \
ICEBERG_S3_SECRET_ACCESS_KEY=... \
python main.py
```

## Config

All via `ICEBERG_` env vars. See `config.py`.
