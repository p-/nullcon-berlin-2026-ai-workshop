#!/usr/bin/env bash

set -e

if [[ $# -ne 1 || -z "$1" || "$1" == -* ]]; then
  echo "Usage: $0 <repo>" >&2
  exit 1
fi

repo="$1"

python -m seclab_taskflow_agent -t seclab_taskflows.taskflows.audit.fetch_source_code -g "repo=$repo"
python -m seclab_taskflow_agent -t seclab_taskflows.taskflows.audit.fetch_security_advisories -g "repo=$repo"
python -m seclab_taskflow_agent -t ai_workshop.taskflows.sol2_variant_finder -g "repo=$repo"