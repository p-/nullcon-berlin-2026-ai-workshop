#!/usr/bin/env bash

set -e

# script that removes the data and log directories and cleans up Docker containers
# so that a new run can be start without old artifacts

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
unset DATA_DIR LOG_DIR
source "$repo_root/.env"

for path in "${DATA_DIR:-}" "${LOG_DIR:-}"; do
	if [[ -z "$path" || "$path" != /* || "$(realpath -m -- "$path")" == / || "$(realpath -m -- "$path")" == "$repo_root" ]]; then
		echo "DATA_DIR and LOG_DIR must be absolute, non-root paths outside the repository root." >&2
		exit 1
	fi
done

container_ids="$(docker ps -aq)"
if [[ -n "$container_ids" ]]; then
	mapfile -t containers <<< "$container_ids"
	docker rm -f "${containers[@]}"
fi

rm -rf -- "$DATA_DIR" "$LOG_DIR"
mkdir -p -- "$DATA_DIR" "$LOG_DIR"
