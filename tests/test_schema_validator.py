import sys
from pathlib import Path

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from schema_validator import SchemaValidator  # noqa: E402


def test_validate_minimal_indicator_yaml(tmp_path: Path):
    yaml_content = """
_metadata:
  version: "2.0.0"
  generated_at: "2026-01-20T00:00:00Z"
  source: "test"
  total_indicators: 1
indicators:
  SP.POP.TOTL:
    code: "SP.POP.TOTL"
    name: "Population, total"
    source_id: "2"
    source_name: "World Development Indicators"
    topic_ids: ["8"]
    topic_names: ["Health"]
    description: "Population"
    unit: "people"
    source_org: "World Bank"
    note: ""
    limited_data: false
"""
    yaml_file = tmp_path / "_wbopendata_indicators.yaml"
    yaml_file.write_text(yaml_content, encoding="utf-8")

    validator = SchemaValidator(Path(__file__).resolve().parents[1] / "config" / "schema_yaml_v2.json")
    result = validator.validate_yaml(yaml_file, "indicators_file")

    assert result["valid"] is True
    assert result["error"] is None
