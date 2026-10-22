import logging
import re
from pathlib import Path
from typing import Literal

import aiofiles
from fastmcp import FastMCP
from jinja2 import Environment, StrictUndefined
from pydantic import Field
from seclab_taskflow_agent.path_utils import log_file_name, mcp_data_dir

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(levelname)s - %(message)s",
    filename=log_file_name("mcp_variant_report.log"),
    filemode="a",
)

mcp = FastMCP("VariantReport")

REPORT_DIR = (mcp_data_dir("ai_workshop", "variant_report", "DATA_DIR") / "variant-report").resolve()
ADVISORY_ID_RE = re.compile(r"^[A-Za-z0-9-]+$")

# Markdown output, so HTML autoescaping is intentionally disabled.
REPORT_TEMPLATE = Environment(
    autoescape=False, undefined=StrictUndefined, keep_trailing_newline=True
).from_string(
    """# Variant report: {{ advisory_id }}

## Does a vulnerable variant exist?

{{ variant_exists }}

## Summary

**Title:** {{ title }}
- **CVE:** {{ cve }}
- **Package:** {{ package }} (`{{ ecosystem }}`)
- **Affected release:** {{ affected_release }}
- **First patched release:** {{ first_patched_release }}
- **Upstream severity:** {{ upstream_severity }}

## Affected source code

{{ affected_source_code }}
{% if additional_chapters %}
{{ additional_chapters }}
{% endif %}"""
)


def _single_line(value: str) -> str:
    return " ".join(value.split())


def _report_path(advisory_id: str) -> Path | None:
    if not ADVISORY_ID_RE.fullmatch(advisory_id):
        return None
    path = (REPORT_DIR / f"{advisory_id}-variant-report.md").resolve()
    if path.parent != REPORT_DIR:
        return None
    return path


@mcp.tool()
async def write_variant_report(
    advisory_id: str = Field(description="The advisory id, e.g. GHSA-m2qf-hxjv-5gpq"),
    variant_exists: Literal["Yes", "No"] = Field(description="Does a vulnerable variant exist?"),
    title: str = Field(description="Advisory title, e.g. fallback key is used instead of current signing key"),
    cve: str = Field(description="CVE id, e.g. CVE-2025-47278, or N/A if none"),
    package: str = Field(description="Affected package name, e.g. Flask"),
    ecosystem: str = Field(description="Package ecosystem, e.g. pip"),
    affected_release: str = Field(description="Affected release(s), e.g. 3.1.0"),
    first_patched_release: str = Field(description="First patched release, e.g. 3.1.1"),
    upstream_severity: str = Field(description="Upstream severity, e.g. Low"),
    affected_source_code: str = Field(
        description="Markdown listing the affected source code (files, functions, line numbers, snippets)"
    ),
    additional_chapters: str = Field(
        default="",
        description="Optional freestyle Markdown chapters (use ## headings) appended after the affected source code",
    ),
):
    """
    Write a Markdown variant report for the given advisory.
    The report is stored as <advisory_id>-variant-report.md. Existing reports are overwritten.
    """
    path = _report_path(advisory_id)
    if path is None:
        logging.warning("Rejected invalid advisory id: %r", advisory_id)
        return "Invalid advisory id. Only letters, digits and dashes (-) are allowed."
    report = REPORT_TEMPLATE.render(
        advisory_id=advisory_id,
        variant_exists=variant_exists,
        title=_single_line(title),
        cve=_single_line(cve),
        package=_single_line(package),
        ecosystem=_single_line(ecosystem),
        affected_release=_single_line(affected_release),
        first_patched_release=_single_line(first_patched_release),
        upstream_severity=_single_line(upstream_severity),
        affected_source_code=affected_source_code.strip(),
        additional_chapters=additional_chapters.strip(),
    )
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    async with aiofiles.open(path, "w", encoding="utf-8") as f:
        await f.write(report)
    logging.info("Wrote variant report %s", path)
    return f"Variant report written to {path.name}"


if __name__ == "__main__":
    mcp.run(show_banner=False)
