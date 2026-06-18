from datetime import UTC, datetime, timedelta
from typing import Any, cast
from unittest.mock import MagicMock

import pytest
from pyiceberg.catalog import Catalog
from pyiceberg.table import Table
from pytest_mock import MockerFixture

from config import Settings
from maintenance.iceberg import build_catalog, expire_table, process_table


class TestBuildCatalog:
    def test_passes_settings(self, mocker: MockerFixture) -> None:
        mock_load = mocker.patch("maintenance.iceberg.load_catalog")
        s = Settings(
            nessie_uri="http://n:19120",
            s3_endpoint="https://s3.example.com",
            s3_access_key_id="key",
            s3_secret_access_key="secret",  # type: ignore[arg-type]
        )
        build_catalog(s)
        mock_load.assert_called_once()
        kwargs: dict[str, Any] = mock_load.call_args.kwargs
        assert kwargs["uri"] == "http://n:19120"
        assert kwargs["default_warehouse"] == "warehouse"


class TestExpireTable:
    @pytest.fixture
    def cutoff(self) -> datetime:
        return datetime.now(UTC) - timedelta(days=30)

    @pytest.fixture
    def table(self) -> MagicMock:
        t = MagicMock(spec=Table)
        t.snapshots.return_value = ["s1", "s2", "s3"]
        return t

    @pytest.mark.parametrize(
        ("dry_run", "expected_snapshots"),
        [
            (True, 0),
            (False, 2),
        ],
    )
    def test_expire(self, table: MagicMock, cutoff: datetime, dry_run: bool, expected_snapshots: int) -> None:
        if not dry_run:
            table.snapshots.side_effect = [["s1", "s2", "s3"], ["s3"]]

        result = expire_table(cast(Table, table), cutoff, dry_run=dry_run)
        assert result == expected_snapshots

        if dry_run:
            table.maintenance.expire_snapshots.assert_not_called()


class TestProcessTable:
    @pytest.fixture
    def catalog(self) -> MagicMock:
        return MagicMock(spec=Catalog)

    @pytest.fixture
    def cutoff(self) -> datetime:
        return datetime.now(UTC)

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
        mocker: MockerFixture,
        catalog: MagicMock,
        cutoff: datetime,
        error_on: str | None,
        exception: Exception | None,
        expected: int,
    ) -> None:
        table = MagicMock(spec=Table)
        table.snapshots.return_value = ["s1"]

        if error_on == "load":
            catalog.load_table.side_effect = exception
        else:
            catalog.load_table.return_value = table

        if error_on == "expire":
            mocker.patch("maintenance.iceberg.expire_table", side_effect=exception)
        else:
            mocker.patch("maintenance.iceberg.expire_table", return_value=expected)

        result = process_table(("ns", "tbl"), cast(Catalog, catalog), cutoff, dry_run=False)
        assert result == expected
