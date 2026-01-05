# wbopendata Examples

[← Back to README](../../README.md) | [Examples Gallery](../examples_gallery.md) | [FAQ](../FAQ.md)

---

## Available Resources

| Resource | Description |
|----------|-------------|
| **[Examples Gallery](../examples_gallery.md)** | Visual guide with code snippets and embedded figures |
| **[Example Output](examples_output.md)** | Formatted output from running examples |
| [basic_usage.do](basic_usage.do) | Runnable Stata code - beginner level |
| [advanced_usage.do](advanced_usage.do) | Runnable Stata code - intermediate level |
| [output/](output/) | Raw log files and generated graphs |

---

## Basic Usage Examples

The [basic_usage.do](basic_usage.do) file covers:

1. Download a single indicator for all countries
2. Download multiple indicators
3. Download for specific countries
4. Download by topic
5. Get latest available value only
6. Specify year range
7. Add country metadata (match option)
8. Suppress metadata display
9. Filter countries vs aggregates
10. Export to different formats

---

## Advanced Usage Examples

The [advanced_usage.do](advanced_usage.do) file covers:

1. Create panel dataset with multiple indicators
2. Cross-country comparison with visualization
3. Regional aggregation
4. Time series analysis
5. Income group comparison
6. Using return values
7. Batch download multiple topics
8. Creating maps (requires spmap)
9. Programmatic indicator selection
10. Export formatted tables

---

## Running the Examples

```stata
* Navigate to the examples directory
cd "path/to/wbopendata/doc/examples"

* Run basic examples
do basic_usage.do

* Run advanced examples
do advanced_usage.do

* Run all examples and save logs to output/
do run_examples.do
```

---

## Output Logs

Pre-generated log files from running the examples are available in the [output/](output/) directory:

- [basic_usage_log.txt](output/basic_usage_log.txt) - Output from basic examples
- [advanced_usage_log.txt](output/advanced_usage_log.txt) - Output from advanced examples

---

## Related Documentation

- [FAQ](../FAQ.md) - Troubleshooting common issues
- [Full Help File](../wbopendata.md) - Complete documentation
- [Test Protocol](../../qa/test_protocol.md) - Testing checklist

---

*Last updated: January 2026 (v17.7)*
