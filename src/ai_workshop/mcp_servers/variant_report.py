import logging
import re
from pathlib import Path

import aiofiles
from fastmcp import FastMCP
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
    report: str = Field(description="The variant report in Markdown format"),
):
    """
    Write a Markdown variant report for the given advisory.
    The report is stored as <advisory_id>-variant-report.md. Existing reports are overwritten.
    """
    path = _report_path(advisory_id)
    if path is None:
        logging.warning("Rejected invalid advisory id: %r", advisory_id)
        return "Invalid advisory id. Only letters, digits and dashes (-) are allowed."
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    async with aiofiles.open(path, "w", encoding="utf-8") as f:
        await f.write(report)
    logging.info("Wrote variant report %s", path)
    return f"Variant report written to {path.name}"


if __name__ == "__main__":
    mcp.run(show_banner=False)
