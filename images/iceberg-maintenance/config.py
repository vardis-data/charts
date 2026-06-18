from typing import ClassVar

from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuration loaded from environment variables prefixed with ``ICEBERG_``.

    All fields can be set via environment variables (e.g. ``ICEBERG_NESSIE_URI``).
    Required fields have no default value.
    """

    model_config: ClassVar[SettingsConfigDict] = SettingsConfigDict(env_prefix="ICEBERG_", case_sensitive=False)

    nessie_uri: str = ""
    """Base URL of the Nessie Iceberg REST catalog (e.g. ``http://lakehouse-nessie:19120``)."""
    warehouse: str = "warehouse"
    """Nessie warehouse name used as the catalog default warehouse."""
    retention_days: int = 30
    """Number of days to retain snapshots. Snapshots older than this are expired."""
    dry_run: bool = False
    """If ``True``, log what would be done without making changes."""
    s3_endpoint: str = ""
    """S3-compatible endpoint URL (e.g. ``https://nbg1.your-objectstorage.com``)."""
    s3_region: str = ""
    """S3 region (e.g. ``nbg1``)."""
    s3_path_style: bool = True
    """Whether to use path-style S3 access (``True`` for Hetzner, MinIO)."""
    s3_access_key_id: str = ""
    """S3 access key ID."""
    s3_secret_access_key: SecretStr = SecretStr("")
    """S3 secret access key."""
    orphan_cleanup_enabled: bool = True
    """Whether to remove orphan files after snapshot expiration."""
