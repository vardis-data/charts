import sys

from httpx import ConnectError, HTTPStatusError, get
from loguru import logger

from config import Settings
from maintenance.iceberg import run


def main() -> None:
    settings = Settings()

    logger.info(f"Nessie URI: {settings.nessie_uri}")
    logger.info(f"Warehouse: {settings.warehouse}")
    logger.info(f"Retention: {settings.retention_days} days")
    logger.info(f"Dry run: {settings.dry_run}")

    try:
        _ = get(f"{settings.nessie_uri}/v2/namespaces").raise_for_status()
    except ConnectError:
        logger.error("Nessie catalog is not reachable")
        sys.exit(1)
    except HTTPStatusError as e:
        logger.error(f"Nessie catalog returned {e.response.status_code}")
        sys.exit(1)

    logger.info("Nessie catalog is healthy")

    try:
        run(settings)
    except Exception:
        logger.exception("Maintenance failed")
        sys.exit(1)


if __name__ == "__main__":
    main()
