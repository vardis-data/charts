from datetime import datetime
from typing import cast
from unittest.mock import MagicMock, patch

import pytest
from pyiceberg.catalog import Catalog
from pyiceberg.table import Table

from config import Settings
from maintenance.iceberg import build_catalog, expire_table, process_table


class TestBuildCatalog:
    def test_passes_settings(self) -> None:
        with patch("maintenance.iceberg.load_catalog") as mock_load:
            s = Settings(
                nessie_uri="http://n:19120",
                s3_endpoint="https://s3.example.com",
                s3_access_key_id="key",
                s3_secret_access_key="secret",
            )
            catalog = build_catalog(s)
            assert catalog is not None
            mock_load.assert_called_once()


class TestExpireTable:
    @pytest.mark.parametrize(
        ("dry_run", "expected"),
        [(True, 0), (False, 2)],
    )
    def test_expire(self, table: MagicMock, cutoff: datetime, dry_run: bool, expected: int) -> None:
        if not dry_run:
            table.snapshots.side_effect = [["s1", "s2", "s3"], ["s3"]]

        result = expire_table(cast(Table, table), cutoff, dry_run=dry_run)
        assert result == expected

        if dry_run:
            table.maintenance.expire_snapshots.assert_not_called()


class TestProcessTable:
    @pytest.mark.parametrize(
        ("error_on", "exception", "expected"),
        [
            ("load", RuntimeError("gone"), 0),
            ("expire", RuntimeError("boom"), 0),
            (None, None, 3),
        ],
        ids=["load-fails", "expire-fails", "success"],
    )
    def test_process(
        self,
        catalog: MagicMock,
        cutoff: datetime,
        error_on: str | None,
        exception: RuntimeError | None,
        expected: int,
    ) -> None:
        table = MagicMock(spec=Table)
        table.snapshots.return_value = ["s1"]

        if error_on == "load":
            catalog.load_table.side_effect = exception
        else:
            catalog.load_table.return_value = table

        patcher: object

        if error_on == "expire":
            patcher = patch("maintenance.iceberg.expire_table", side_effect=exception)
        else:
            patcher = patch("maintenance.iceberg.expire_table", return_value=expected)

        with patcher:
            result = process_table(("ns", "tbl"), cast(Catalog, catalog), cutoff, dry_run=False)
            assert result == expected
