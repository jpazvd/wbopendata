"""Utility functions to summarize YAML changes across runs."""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Dict, Optional, Set

import yaml

logger = logging.getLogger(__name__)


class DiffAnalyzer:
    """Compute lightweight diffs between old and new metadata files."""

    def load_keys(self, yaml_path: Path, section: Optional[str] = None) -> Set[str]:
        """Load the set of record keys for the given YAML file."""
        yaml_path = Path(yaml_path)
        if not yaml_path.exists():
            return set()

        with open(yaml_path, "r", encoding="utf-8") as handle:
            payload = yaml.safe_load(handle) or {}

        section_key = section or self._infer_section(yaml_path)
        records = payload.get(section_key, {})
        if not isinstance(records, dict):
            return set()
        return set(records.keys())

    def snapshot(self, path_map: Dict[str, Path]) -> Dict[str, Set[str]]:
        """Capture current keys for multiple YAML files."""
        return {variant: self.load_keys(path, section=variant) for variant, path in path_map.items()}

    @staticmethod
    def summarize(old_keys: Set[str], new_keys: Set[str]) -> Dict[str, int]:
        """Summarize added and removed keys between two sets."""
        added = new_keys - old_keys
        removed = old_keys - new_keys
        return {
            "before": len(old_keys),
            "after": len(new_keys),
            "added": len(added),
            "removed": len(removed),
        }

    def compare_paths(self, old_path: Path, new_path: Path, section: Optional[str] = None) -> Dict[str, int]:
        """Compare two YAML files and return a summary diff."""
        old_keys = self.load_keys(old_path, section)
        new_keys = self.load_keys(new_path, section)
        return self.summarize(old_keys, new_keys)

    def _infer_section(self, yaml_path: Path) -> str:
        name = yaml_path.name.lower()
        if "indicator" in name:
            return "indicators"
        if "source" in name:
            return "sources"
        if "topic" in name:
            return "topics"
        raise ValueError(f"Cannot infer YAML section from filename: {yaml_path}")
