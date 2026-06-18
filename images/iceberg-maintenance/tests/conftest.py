from datetime import UTC, datetime, timedelta
from unittest.mock import MagicMock

import pytest
from pyiceberg.catalog import Catalog
from pyiceberg.table import Table


@pytest.fixture
def cutoff() -> datetime:
    return datetime.now(UTC) - timedelta(days=30)


@pytest.fixture
def catalog() -> MagicMock:
    return MagicMock(spec=Catalog)


@pytest.fixture
def table() -> MagicMock:
    t = MagicMock(spec=Table)
    t.snapshots.return_value = ["s1", "s2", "s3"]
    return t
