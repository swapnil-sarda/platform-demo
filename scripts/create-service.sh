#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <service-name> <owner-team>" >&2
  exit 1
fi

service_name="$1"
owner_team="$2"

if ! [[ "$service_name" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
  echo "ERROR: service-name must be a lowercase DNS label, for example: orders-api" >&2
  exit 1
fi

if ! [[ "$owner_team" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
  echo "ERROR: owner-team must be a lowercase label, for example: payments-team" >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template_dir="${repo_root}/service-template"
destination_dir="${repo_root}/services/${service_name}"

if [[ ! -d "$template_dir" ]]; then
  echo "ERROR: service template directory not found: ${template_dir}" >&2
  exit 1
fi

if [[ -e "$destination_dir" ]]; then
  echo "ERROR: service already exists: ${destination_dir}" >&2
  exit 1
fi

cp -R "$template_dir" "$destination_dir"

python3 - "$destination_dir" "$service_name" "$owner_team" <<'PY'
from pathlib import Path
import sys

destination = Path(sys.argv[1])
service_name = sys.argv[2]
owner_team = sys.argv[3]

for path in destination.rglob("*"):
    if path.is_file():
        content = path.read_text()
        content = content.replace("__SERVICE_NAME__", service_name)
        content = content.replace("__OWNER_TEAM__", owner_team)
        path.write_text(content)
PY

echo "Created ${destination_dir}"
echo
echo "Next steps:"
echo "  kubectl kustomize services/${service_name}"
echo "  git add services/${service_name}"
echo "  git commit -m \"feat: add ${service_name} service configuration\""
echo "  git push"
