# wbopendata Documentation

[← Back to Main README](../README.md) | [GitHub](https://github.com/jpazvd/wbopendata)

---

Welcome to the wbopendata documentation hub. This directory contains guides, examples, reference materials, and roadmap information.

---

## 📚 Quick Navigation

### [User Guide](user-guide/)
Start here to learn how to use wbopendata. Includes examples, FAQ, and step-by-step tutorials.

- **[Examples Gallery](user-guide/examples_gallery.md)** – Visual showcase with code snippets and embedded figures
- **[Examples with Code](user-guide/examples/)** – Runnable Stata do-files (basic, advanced, and specialized examples)
- **[FAQ](user-guide/FAQ.md)** – Troubleshooting and answers to common questions

### [Reference](../../.github/)
Technical documentation and best practices (workspace-wide).

- **[STATA ADO Best Practices](../../.github/STATA_ADO_BEST_PRACTICES.md)** – Coding standards and conventions for Stata ADO files

### [Roadmap](roadmap/)
Future directions and planned enhancements.

- **[ROADMAP](roadmap/ROADMAP.md)** – Planned features, priorities, and version timeline

---

## 📖 Documentation Structure

```
doc/
├── README.md                    # This file - navigation hub
├── wbopendata.md               # Complete help documentation
├── user-guide/
│   ├── examples_gallery.md     # Visual examples with figures
│   ├── FAQ.md                  # Frequently asked questions
│   └── examples/               # Runnable do-files
│       ├── README.md
│       ├── basic_usage.do
│       ├── advanced_usage.do
│       ├── paper_figures.do
│       ├── examples_dyndoc.do
│       ├── output/             # Generated logs and outputs
│       └── assets/             # Supporting images and files
└── roadmap/
    └── ROADMAP.md

../.github/
└── STATA_ADO_BEST_PRACTICES.md  # Workspace-wide ADO standards
```

---

## 🚀 Getting Started

### For New Users
1. **Start with the [User Guide](user-guide/)**
2. **Browse the [Examples Gallery](user-guide/examples_gallery.md)** to see what's possible
3. **Run the [Basic Examples](user-guide/examples/basic_usage.do)** to learn by doing

### For Developers
1. **Review [STATA ADO Best Practices](../../.github/STATA_ADO_BEST_PRACTICES.md)**
2. **Check the [Roadmap](roadmap/ROADMAP.md)** for development priorities
3. **Consult [Complete Help](wbopendata.md)** for detailed API reference

### For Contributors
1. **Read [STATA ADO Best Practices](../../.github/STATA_ADO_BEST_PRACTICES.md)**
2. **Review [Roadmap](roadmap/ROADMAP.md)** for known issues and planned features
3. **Check [Testing Protocol](../qa/test_protocol.md)** for quality guidelines

---

## 📝 Key Resources

| Resource | Purpose |
|----------|---------|
| [Complete Help](wbopendata.md) | Full API documentation and syntax reference |
| [Examples](user-guide/examples/) | Executable Stata code for all use cases |
| [FAQ](user-guide/FAQ.md) | Solutions to common problems |
| [Best Practices](../../.github/STATA_ADO_BEST_PRACTICES.md) | Coding standards and design patterns (workspace-wide) |
| [Roadmap](roadmap/ROADMAP.md) | Future features and development priorities |

---

## 🔗 Related Links

- **[Project README](../README.md)** – Overview and installation instructions
- **[GitHub Issues](https://github.com/jpazvd/wbopendata/issues)** – Report bugs or request features
- **[Changelog](../CHANGELOG.md)** – Version history and release notes
- **[Testing Protocol](../qa/test_protocol.md)** – Quality assurance procedures

---

## 💡 Tips

- **Search within examples**: Use grep or your editor's search to find specific indicators
- **Generate new examples**: Copy `basic_usage.do` or `advanced_usage.do` as a template
- **Check compatibility**: See [Roadmap](roadmap/ROADMAP.md) for known issues by version
- **Get help**: Post issues on [GitHub](https://github.com/jpazvd/wbopendata/issues)

---

**Last Updated**: January 2026 | **Version**: 17.7.1
