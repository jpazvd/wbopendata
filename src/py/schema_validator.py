"""Validate generated YAML files against the wbopendata schema v2.0.0."""

from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any, Dict, Iterable, Optional

import yaml
from jsonschema import ValidationError, validate

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SCHEMA_PATH = PROJECT_ROOT / "config" / "schema_yaml_v2.json"


class SchemaValidator:
    """Validate YAML files produced by the metadata pipeline."""

    def __init__(self, schema_path: Path = DEFAULT_SCHEMA_PATH):
        self.schema_path = Path(schema_path).resolve()
        if not self.schema_path.exists():
            raise FileNotFoundError(f"Schema file not found: {self.schema_path}")

        with open(self.schema_path, "r", encoding="utf-8") as handle:
            self.schema: Dict[str, Any] = json.load(handle)

        self.definitions = self.schema.get("definitions", {})
        if not self.definitions:
            raise ValueError("Schema definitions are missing or empty.")

    def validate_yaml(self, yaml_path: Path, variant: Optional[str] = None) -> Dict[str, Any]:
        """Validate a YAML file against the selected schema definition.

        Args:
            yaml_path: Path to the YAML file to validate.
            variant: Optional schema variant name; inferred from filename when omitted.

        Returns:
            Dict with validation result: {"valid": bool, "variant": str, "error": Optional[str]}.
        """
        yaml_path = Path(yaml_path).resolve()
        variant_name = variant or self._infer_variant(yaml_path)
        schema = self._select_schema(variant_name)

        with open(yaml_path, "r", encoding="utf-8") as handle:
            payload = yaml.safe_load(handle) or {}

        try:
            validate(instance=payload, schema=schema)
            return {"valid": True, "variant": variant_name, "error": None}
        except ValidationError as exc:  # pragma: no cover - clarity for humans
            logger.error("Validation failed for %s (%s): %s", yaml_path, variant_name, exc)
            return {"valid": False, "variant": variant_name, "error": str(exc)}

    def validate_many(self, files: Iterable[Path]) -> Dict[str, Dict[str, Any]]:
        """Validate multiple YAML files, keyed by filename."""
        results: Dict[str, Dict[str, Any]] = {}
        for path in files:
            result = self.validate_yaml(path)
            results[Path(path).name] = result
        return results

    def _select_schema(self, variant_name: str) -> Dict[str, Any]:
        variant = self.definitions.get(variant_name)
        if variant is None:
            raise ValueError(f"Unknown schema variant: {variant_name}")
        # Include shared definitions so that $ref targets resolve
        return {
            "$schema": self.schema.get("$schema", "http://json-schema.org/draft-07/schema#"),
            "definitions": self.definitions,
            **variant,
        }

    def _infer_variant(self, yaml_path: Path) -> str:
        name = yaml_path.name.lower()
        if "indicator" in name:
            return "indicators_file"
        if "source" in name:
            return "sources_file"
        if "topic" in name:
            return "topics_file"
        raise ValueError(f"Cannot infer schema variant from filename: {yaml_path}")
