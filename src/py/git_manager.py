"""Lightweight Git helpers for the metadata automation pipeline."""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Iterable

from git import Repo
from git.exc import InvalidGitRepositoryError

logger = logging.getLogger(__name__)


class GitManager:
    """Encapsulate common Git actions (stage, commit, tag)."""

    def __init__(self, repo_path: Path | None = None):
        root_hint = Path(repo_path) if repo_path else Path(__file__).resolve()
        try:
            self.repo = Repo(root_hint, search_parent_directories=True)
        except InvalidGitRepositoryError as exc:
            raise ValueError(f"Git repository not found from {root_hint}") from exc

        if self.repo.bare:
            raise ValueError(f"Repository appears to be bare at {root_hint}")

        self.root = Path(self.repo.working_tree_dir)

    def stage(self, paths: Iterable[Path]) -> None:
        file_list = self._to_repo_rel_paths(paths)
        if not file_list:
            return
        self.repo.index.add(file_list)
        logger.info("Staged %d files", len(file_list))

    def has_changes(self, paths: Iterable[Path] | None = None) -> bool:
        if paths is None:
            return self.repo.is_dirty(untracked_files=True)

        file_list = self._to_repo_rel_paths(paths)
        if not file_list:
            return False

        tracked_changes = bool(self.repo.index.diff(None, file_list))
        untracked_targets = set(file_list)
        untracked_matches = any(f in untracked_targets for f in self.repo.untracked_files)
        return tracked_changes or untracked_matches

    def commit(self, message: str) -> None:
        self.repo.index.commit(message)
        logger.info("Created commit: %s", message)

    def tag(self, tag_name: str, message: str | None = None) -> None:
        existing = [tag.name for tag in self.repo.tags]
        if tag_name in existing:
            logger.info("Tag %s already exists; skipping", tag_name)
            return
        self.repo.create_tag(tag_name, message=message)
        logger.info("Created tag: %s", tag_name)

    def _to_repo_rel_paths(self, paths: Iterable[Path]) -> list[str]:
        rel_paths: list[str] = []
        for path in paths:
            resolved = Path(path).resolve()
            try:
                rel_paths.append(str(resolved.relative_to(self.root)))
            except ValueError:
                # If the file is outside the repo root, fall back to absolute
                rel_paths.append(str(resolved))
        return rel_paths
