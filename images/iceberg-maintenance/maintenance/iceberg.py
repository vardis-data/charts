from datetime import UTC, datetime, timedelta

from loguru import logger
from pyiceberg.catalog import Catalog, load_catalog
from pyiceberg.table import Table
from pyiceberg.typedef import Identifier

from config import Settings


def build_catalog(settings: Settings) -> Catalog:
    """Build a pyiceberg catalog connected to the Nessie REST catalog.

    Args:
        settings: Configuration with Nessie URI, warehouse name, and S3 credentials.

    Returns:
        A pyiceberg ``Catalog`` instance ready for table operations.
    """
    return load_catalog(
        "nessie",
        type="nessie",
        uri=settings.nessie_uri,
        default_warehouse=settings.warehouse,
        **{
            "s3.endpoint": settings.s3_endpoint,
            "s3.access-key-id": settings.s3_access_key_id,
            "s3.secret-access-key": settings.s3_secret_access_key.get_secret_value(),
            "s3.region": settings.s3_region,
            "s3.path-style-access": str(settings.s3_path_style).lower(),
        },
    )


def expire_table(table: Table, cutoff: datetime, dry_run: bool) -> int:
    """Expire snapshots older than *cutoff* on a single table.

    Args:
        table: A pyiceberg ``Table`` instance.
        cutoff: Snapshots with timestamp before this are expired.
        dry_run: If ``True``, only log what would happen.

    Returns:
        Number of snapshots expired.
    """
    snapshots = table.snapshots()
    if dry_run:
        logger.info(f"[DRY RUN] Would expire snapshots older than {cutoff.date()}")
        return 0

    table.maintenance.expire_snapshots().older_than(cutoff).commit()
    remaining = len(table.snapshots())
    expired = len(snapshots) - remaining
    return expired


def process_table(table_id: Identifier, catalog: Catalog, cutoff: datetime, dry_run: bool) -> int:
    """Load, log, and expire snapshots for a single table.

    Returns the number of snapshots expired, or 0 on any error.
    """
    try:
        table = catalog.load_table(table_id)
    except Exception as e:
        logger.error(f"Failed to load {table_id}: {e}")
        return 0

    snapshots = table.snapshots()

    logger.info(f"{table_id}: {len(snapshots)} snapshot(s)")

    try:
        expired = expire_table(table, cutoff, dry_run)

        if expired:
            logger.info(f"Expired {expired} snapshot(s)")

        return expired
    except Exception as e:
        logger.error(f"Failed on {table_id}: {e}")
        return 0


def run(settings: Settings) -> None:
    """Expire old Iceberg snapshots across all tables in the Nessie catalog.

    Iterates over every namespace and table, expiring snapshots older than
    ``retention_days``. Protected snapshots (branch/tag heads) are never expired.

    Args:
        settings: Configuration controlling catalog connection and retention.
    """
    cutoff = datetime.now(UTC) - timedelta(days=settings.retention_days)
    logger.info(f"Retention threshold: {cutoff.isoformat()} ({settings.retention_days} days)")

    if settings.dry_run:
        logger.warning("DRY RUN — no changes will be made")

    catalog = build_catalog(settings)
    namespaces = catalog.list_namespaces()
    logger.info(f"Found {len(namespaces)} namespace(s)")

    all_tables = [table for ns in namespaces for table in catalog.list_tables(ns)]
    total_snapshots = sum(process_table(tid, catalog, cutoff, settings.dry_run) for tid in all_tables)
    logger.info(f"Done. Expired {total_snapshots} snapshot(s)")
