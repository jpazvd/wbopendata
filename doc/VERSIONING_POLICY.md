# wbopendata Versioning Policy (ADO / Source Files)

This document describes the versioning rules for wbopendata source files (ADO, helper scripts, help files) and the package release process.

Principles
- Maintain two coordinated version tracks:
  - Package-level (canonical): `CITATION.cff`, `src/w/wbopendata.ado`, `src/stata.toc`, `CHANGELOG.md`.
  - Component-level (per-file): every ADO/internal helper keeps a `vMAJOR.MINOR.PATCH` header.

Per-file versioning
- Use Semantic Versioning semantics per file:
  - Patch: bugfix or non-behavioral changes.
  - Minor: backward-compatible feature additions.
  - Major: breaking API changes.
- Header format examples:
  - `*! _wbopendata_cache v2.0.0 07Feb2026`
  - Normalize legacy headers like `v 10` to `10.0.0` when editing the file.

Package release rules
1. Any file modified in a release MUST have its header version bumped appropriately.
2. Package version in `CITATION.cff` and main `wbopendata.ado` must match for releases.
3. Release type (patch/minor/major) is determined by the highest-impact change included.

Automation
- `scripts/update_component_versions.py` — scans repository headers and outputs a `src/_/__COMPONENT_VERSIONS.yaml` mapping.
- `scripts/check_versions.py <base-ref>` — ensures modified files in a diff have a version bump compared to `<base-ref>`.

Workflow checklist for contributors
- Before opening PR: bump headers for modified files.
- Run `python scripts/update_component_versions.py > src/_/__COMPONENT_VERSIONS.yaml` and commit.
- Add entry to `CHANGELOG.md` with component versions and user-facing notes.
- For release PRs: update `CITATION.cff` and `src/w/wbopendata.ado` package header to the new version.
- Tag release with `git tag -a vX.Y.Z -m "Release vX.Y.Z"` and push.

CI Recommendations
- Add a CI job that runs `python scripts/check_versions.py origin/main` and fails when modified files don't bump version headers.

Migration notes
- Don't mass-rewrite historic files. Normalize headers when you touch a file.
- Logs and tests that record historical versions may remain unchanged.

Contact/Authoring
- Author: João Pedro Azevedo
- Repo policy file: `.github/copilot-instructions.md`
