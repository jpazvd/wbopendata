import sys
from pathlib import Path

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from diff_analyzer import DiffAnalyzer  # noqa: E402


def test_diff_analyzer_counts_added_removed(tmp_path: Path):
    old_yaml = tmp_path / "old.yaml"
    new_yaml = tmp_path / "new.yaml"

    old_yaml.write_text(
        """
_metadata:
  version: "2.0.0"
indicators:
  A:
    code: "A"
    name: "A"
""",
        encoding="utf-8",
    )

    new_yaml.write_text(
        """
_metadata:
  version: "2.0.0"
indicators:
  A:
    code: "A"
    name: "A"
  B:
    code: "B"
    name: "B"
""",
        encoding="utf-8",
    )

    analyzer = DiffAnalyzer()
    summary = analyzer.compare_paths(old_yaml, new_yaml, section="indicators")

    assert summary["before"] == 1
    assert summary["after"] == 2
    assert summary["added"] == 1
    assert summary["removed"] == 0
