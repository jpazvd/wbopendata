from __future__ import annotations

from pathlib import Path
from urllib.request import urlopen
import xml.etree.ElementTree as ET

OUT_DIR = Path("C:/GitHub/myados/wbopendata-dev/tests/parity_out")
URLS = {
    1: "https://api.worldbank.org/v2/indicators?per_page=10000&page=1",
    2: "https://api.worldbank.org/v2/indicators?per_page=10000&page=2",
    3: "https://api.worldbank.org/v2/indicators?per_page=10000&page=3",
}


def _local_name(tag: str) -> str:
    if "}" in tag:
        return tag.split("}", 1)[1]
    return tag


def _download(page: int, url: str) -> Path:
    data = urlopen(url).read()
    path = OUT_DIR / f"indicator_page_{page}.xml"
    path.write_bytes(data)
    return path


def _parse_schema(path: Path) -> dict[str, object]:
    tree = ET.parse(path)
    root = tree.getroot()
    ns = ""
    if "}" in root.tag:
        ns = root.tag.split("}", 1)[0].strip("{")
    indicator_tag = f"{{{ns}}}indicator" if ns else "indicator"
    indicators = root.findall(f".//{indicator_tag}")

    child_tags: set[str] = set()
    indicator_attrs: set[str] = set()
    child_attrs: set[str] = set()

    for ind in indicators:
        indicator_attrs.update(ind.attrib.keys())
        for child in list(ind):
            child_tags.add(_local_name(child.tag))
            child_attrs.update(child.attrib.keys())

    return {
        "count": len(indicators),
        "child_tags": child_tags,
        "indicator_attrs": indicator_attrs,
        "child_attrs": child_attrs,
    }


def _format_list(values: set[str]) -> str:
    if not values:
        return "(none)"
    return ", ".join(sorted(values))


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    pages: dict[int, dict[str, object]] = {}

    for page, url in URLS.items():
        xml_path = _download(page, url)
        pages[page] = _parse_schema(xml_path)

    all_child_tags = set().union(*(p["child_tags"] for p in pages.values()))
    all_indicator_attrs = set().union(*(p["indicator_attrs"] for p in pages.values()))
    all_child_attrs = set().union(*(p["child_attrs"] for p in pages.values()))

    lines: list[str] = [
        "Indicator schema report",
        "========================",
        "",
    ]

    for page in sorted(pages):
        info = pages[page]
        lines.append(f"Page {page} indicators: {info['count']}")
        lines.append(f"Page {page} child tags: {_format_list(info['child_tags'])}")
        lines.append(f"Page {page} indicator attrs: {_format_list(info['indicator_attrs'])}")
        lines.append(f"Page {page} child attrs: {_format_list(info['child_attrs'])}")
        lines.append("")

    lines.append(f"Union child tags: {_format_list(all_child_tags)}")
    lines.append(f"Union indicator attrs: {_format_list(all_indicator_attrs)}")
    lines.append(f"Union child attrs: {_format_list(all_child_attrs)}")
    lines.append("")

    for page in sorted(pages):
        info = pages[page]
        missing = all_child_tags - info["child_tags"]
        if missing:
            lines.append(f"Page {page} missing child tags: {_format_list(missing)}")
    lines.append("")

    report_path = OUT_DIR / "indicator_schema_report.txt"
    report_path.write_text("\n".join(lines), encoding="utf-8")
    print(report_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
