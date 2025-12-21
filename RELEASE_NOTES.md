# Release Notes

## wbopendata v17.1 — Documentation Overhaul & Community Bug Fixes

**Release Date:** December 21, 2025

---

### 🎉 Highlights

This release focuses on community-driven bug fixes, comprehensive documentation improvements, and repository professionalization. Special thanks to our community contributors who reported issues and helped improve the package.

---

### 🐛 Bug Fixes

| Issue | Description | Contributor |
|-------|-------------|-------------|
| [#33](https://github.com/jpazvd/wbopendata/issues/33) | Fixed `latest` option functionality | @lucaslindoso |
| [#35](https://github.com/jpazvd/wbopendata/issues/35) | Fixed country metadata retrieval | @lucaslindoso |
| [#45](https://github.com/jpazvd/wbopendata/issues/45) | Resolved URL construction errors | @lucaslindoso |
| [#46](https://github.com/jpazvd/wbopendata/issues/46) | Fixed varlist option handling | @lucaslindoso |
| [#51](https://github.com/jpazvd/wbopendata/issues/51) | Updated documentation to match API behavior | @daniel-klein |

---

### 📚 New Documentation

- **[FAQ](doc/FAQ.md)** — Common questions compiled from GitHub issues
- **[Examples Gallery](doc/examples_gallery.md)** — Visual showcase with example figures and ready-to-run Stata code
- **Example Do-Files:**
  - [`basic_usage.do`](doc/examples/basic_usage.do) — 10 introductory examples
  - [`advanced_usage.do`](doc/examples/advanced_usage.do) — 10 advanced use cases
- **Enhanced [README](README.md)** — Installation instructions, quick start guide, documentation table, and contributing guidelines
- **Updated Help File** — Added Community Contributors section acknowledging bug reporters

---

### 🧪 Quality Assurance

- **[Test Protocol](qa/test_protocol.md)** — Comprehensive testing checklist for releases
- **[Automated Test Suite](qa/run_tests.do)** — 257-line test script covering all major functionality

---

### 📁 Repository Organization

Reorganized documentation into structured subdirectories:

```
doc/
├── plans/      # Future improvement plans
├── logs/       # Development logs  
├── images/     # Example figures
└── examples/   # Example do-files

qa/             # Quality assurance materials
```

---

### 👥 Community Contributors

We thank the following contributors for their bug reports and suggestions:

- **@ckrf** — Country metadata fixes ([PR #44](https://github.com/jpazvd/wbopendata/pull/44)) 🆕
- **@lucaslindoso** — Issues #33, #35, #45, #46
- **@daniel-klein** — Issue #51
- **@randrescastaneda** — Extensive testing and feedback
- **@zhaowill** — Early adoption and testing

---

### 📦 Installation

```stata
* Install from SSC (recommended)
ssc install wbopendata, replace

* Install from GitHub (latest version)
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main") replace
```

---

### 🔗 Resources

| Resource | Description |
|----------|-------------|
| [Full Documentation](doc/wbopendata.md) | Complete command reference |
| [Examples Gallery](doc/examples_gallery.md) | Visual examples with code |
| [FAQ](doc/FAQ.md) | Frequently asked questions |
| [Report Issues](https://github.com/jpazvd/wbopendata/issues) | Bug reports and feature requests |

---

### 🔀 Merged Pull Requests

- Country metadata fixes by @ckrf in [#44](https://github.com/jpazvd/wbopendata/pull/44)
- v17 by @jpazvd in [#50](https://github.com/jpazvd/wbopendata/pull/50)
- update 20240702 by @jpazvd in [#52](https://github.com/jpazvd/wbopendata/pull/52)
- Develop by @jpazvd in [#53](https://github.com/jpazvd/wbopendata/pull/53)

### 🌟 New Contributors

- **@ckrf** made their first contribution in [#44](https://github.com/jpazvd/wbopendata/pull/44)

---

### Full Changelog

**Compare:** [v16.3...v17.1](https://github.com/jpazvd/wbopendata/compare/v16.3...v17.1)

---

## Previous Releases

### v17.0 (2024)

- Updated to World Bank API v2
- Added support for new indicators
- Performance improvements

### v16.x and earlier

See [commit history](https://github.com/jpazvd/wbopendata/commits/main) for details.

---

*For questions or support, visit [jpazvd.github.io](https://jpazvd.github.io) or open an [issue](https://github.com/jpazvd/wbopendata/issues).*
